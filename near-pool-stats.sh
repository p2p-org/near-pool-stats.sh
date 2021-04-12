#!/bin/sh

# Usage: ./near-pool-stats.sh <POOL_ACCOUNT_ID>
# E.g. ./near-pool-stats.sh p2p-org.poolv1.near

ACCOUNT_POOL="$1"

near_view() (
	CONTRACT_ID="$1"
	CONTRACT_METHOD="$2"
	CONTRACT_ARGS=$(printf '%s' "$3" | base64)
	REQUEST_PARAMS=$(printf '
	{
		"jsonrpc": "2.0",
		"id": "dontcare",
		"method": "query",
		"params": {
			"request_type": "call_function",
			"finality": "final",
			"account_id": "%s",
			"method_name": "%s",
			"args_base64": "%s"
		}
	}
	' "$CONTRACT_ID" "$CONTRACT_METHOD" "$CONTRACT_ARGS")
	curl -s -X POST \
     		-H 'Content-Type: application/json' \
     		-d "$REQUEST_PARAMS" \
     		https://rpc.mainnet.near.org \
			| jq -r ".result.result | implode"
)

get_accounts() (
	LIMIT=100
	INDEX=0
	ACCOUNTS='[]'
	while
		GET_ACC_ARGS=$(printf '{"limit": %s, "from_index": %s}' "$LIMIT" "$INDEX")
		NEW_ACCOUNTS=$(near_view "$ACCOUNT_POOL" get_accounts "$GET_ACC_ARGS")
		COUNT=$(printf '%s' "$NEW_ACCOUNTS" | jq length)
		INDEX=$(( INDEX + COUNT ))
		ACCOUNTS=$(printf '%s%s' "$ACCOUNTS" "$NEW_ACCOUNTS" \
			| jq  -s '.[0]=([.[]]|flatten)|.[0]')
		test "$COUNT" -eq "$LIMIT"
	do :; done
	printf '%s' "$ACCOUNTS"
)

get_pool_owner() {
	near_view "$1" get_owner_id | jq -r .
}

is_lockup() {
	printf '%s' "$1" | grep -Eq '^[[:alnum:]]{40}\.lockup\.near$'
}

lockup_owner() {
	near_view "$1" get_owner_account_id | jq -r .
}

is_foundation() {
	printf '%s' "$1" | grep -Eq 'nfendowment[[:digit:]]{2}.near'
}

near_price() {
	curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=near&vs_currencies=usd" \
	        -H  "accept: application/json" \
		| jq .near.usd
}

is_own() {
	test "$ACCID_OWN" = "$1"
}

print_accts() (
	ACCOUNTS=$(printf '%s' "$1" | tr ';' '\n')
	COUNT=$(printf '%s\n' "$ACCOUNTS" | wc -l)
	printf '%s\n' "$ACCOUNTS" | while read -r ACCBAL ACCID; do
		ACCBALUSD=$(printf '%s*%s\n' "$ACCBAL" "$NEAR_PRICE" | bc)
		printf "%14s NEAR  (%14s USD) -- %s\n" "$ACCBAL" "$ACCBALUSD" "$ACCID"
	done
	test "$COUNT" -eq 1 && return
	TOTAL=$(printf '%s\n' "$ACCOUNTS" | ( 
		TOTAL=0; 
		while IFS=' ' read -r ACCBAL _; do
			TOTAL=$(printf '%s + %s\n' "$TOTAL" "$ACCBAL" | bc)
		done
	       	printf '%s\n' "$TOTAL" 
		)
	)
	TOTAL_USD=$(printf '%s*%s\n' "$TOTAL" "$NEAR_PRICE" | bc)
	printf '%14s NEAR  (%14s USD) -- Subtotal across %s accounts\n' "$TOTAL" "$TOTAL_USD" "$COUNT"
)

ACCID_OWN=$(get_pool_owner "$ACCOUNT_POOL")
ALL_ACCOUNTS_JSON=$(get_accounts)
ACCOUNTS_JSON=$(printf '%s' "$ALL_ACCOUNTS_JSON" | jq 'map(select(.staked_balance != "0")) | sort_by(.staked_balance|tonumber) | reverse')
ACCOUNT_IDS=$(printf '%s' "$ACCOUNTS_JSON" | jq -r '.[]|.account_id')
ACCOUNT_BALANCES=$(printf '%s' "$ACCOUNTS_JSON" | jq -r '.[]|.staked_balance' | awk '{ printf "%.4f\n", $1 * 10^-24 }')
TOTAL_COUNT=$(printf '%s' "$ALL_ACCOUNTS_JSON" | jq 'length')
NON_EMPTY_COUNT=$(printf '%s' "$ACCOUNTS_JSON" | jq 'length')
EMPTY_COUNT=$(( TOTAL_COUNT - NON_EMPTY_COUNT ))
NEAR_PRICE=$(near_price)

OWN_ACCOUNTS=""
FND_ACCOUNTS=""
DELEG_ACCOUNTS=""
TOTAL_TOTAL=0

for i in $(seq 1 "$NON_EMPTY_COUNT"); do
	ACCID=$(printf '%s' "$ACCOUNT_IDS" | sed -n "${i}p")
	ACCBAL=$(printf '%s' "$ACCOUNT_BALANCES" | sed -n "${i}p")
	ACCFMT="$ACCBAL $ACCID"

	if is_lockup "$ACCID"; then
		ACCID=$(lockup_owner "$ACCID")
		ACCFMT="$ACCBAL $ACCID (via lockup)"
	fi

	TOTAL_TOTAL=$(printf '%s + %s\n' "$TOTAL_TOTAL" "$ACCBAL" | bc)
	if is_own "$ACCID"; then 
		OWN_ACCOUNTS="${OWN_ACCOUNTS}${ACCFMT};"
	elif is_foundation "$ACCID"; then
		FND_ACCOUNTS="${FND_ACCOUNTS}${ACCFMT};"
	else
		DELEG_ACCOUNTS="${DELEG_ACCOUNTS}${ACCFMT};"
	fi
done

printf "Current date: %s\n" "$(date -u)"
printf "Current NEAR price: %s USD (source: CoinGecko).\n" "$NEAR_PRICE"

printf "\nViewing delegations data for the staking pool %s\n" "$ACCOUNT_POOL"

printf "\nPool owner's stake, including validator fees:\n"
print_accts "$OWN_ACCOUNTS"

if [ -n "$FND_ACCOUNTS" ]; then
       printf "\nNEAR Foundation delegation:\n"
	print_accts "$FND_ACCOUNTS"
fi

if [ -n "$DELEG_ACCOUNTS" ]; then
	printf "\nMiscellaneous delegations:\n"
	print_accts "$DELEG_ACCOUNTS"
fi

printf "\n"
print_accts "$TOTAL_TOTAL Total across $NON_EMPTY_COUNT non-empty account(s)"
printf '%45sand %s accounts with zero staked balance\n' ' ' "$EMPTY_COUNT"
