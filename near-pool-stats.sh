#!/bin/sh

# Usage: ./near-pool-stats.sh <POOL_ACCOUNT_ID> "<OWN_ACCOUNT_ID_1> [<OWN_ACCOUNT_ID_2 [...]]"
# E.g. ./near-pool-stats.sh p2p-org.poolv1.near p2p-org.near

ACCOUNT_POOL="$1"
ACCOUNTS_OWN="$2"

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
		GET_ACC_ARGS=`printf '{"limit": %s, "from_index": %s}' "$LIMIT" "$INDEX"`
		NEW_ACCOUNTS=`near_view "$ACCOUNT_POOL" get_accounts "$GET_ACC_ARGS"`
		COUNT=`printf '%s' "$NEW_ACCOUNTS" | jq length`
		INDEX=`expr "$INDEX" + "$COUNT"`
		ACCOUNTS=`printf '%s%s' "$ACCOUNTS" "$NEW_ACCOUNTS" \
			| jq  -s '.[0]=([.[]]|flatten)|.[0]'`
		test "$COUNT" -eq "$LIMIT"
	do :; done
	printf '%s' "$ACCOUNTS"
)

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
	printf '%s' "$ACCOUNTS_OWN" | grep -q "$1"
}

ACCOUNTS_JSON=`get_accounts`
accounts() {
       printf '%s' "$ACCOUNTS_JSON"
}

ACCOUNTS_JSON=`accounts | jq 'sort_by(.staked_balance|tonumber) | reverse'`
ACCOUNT_IDS=`accounts | jq -r '.[]|.account_id'`
ACCOUNT_BALANCES=`accounts | jq -r '.[]|.staked_balance' | awk '{ printf "%.4f\n", $1 * 10^-24 }'`
TOTAL_COUNT=`accounts | jq 'length'`
TOTAL_TOTAL=0
NEAR_PRICE=`near_price`

printf "Current date: %s\n" "`date -u`"
printf "Current NEAR price: %s USD (source: CoinGecko).\n" "$NEAR_PRICE"

printf "\nViewing delegations data for the staking pool %s\n" "$ACCOUNT_POOL"

OWN_ACCOUNTS=""
FND_ACCOUNTS=""
DELEG_ACCOUNTS=""

for i in `seq 1 $TOTAL_COUNT`; do
	ACCID=`printf '%s' "$ACCOUNT_IDS" | sed -n ${i}p`
	ACCBAL=`printf '%s' "$ACCOUNT_BALANCES" | sed -n ${i}p`
	ACCFMT="$ACCBAL $ACCID"

	if is_lockup "$ACCID"; then
		ACCID=`lockup_owner "$ACCID"`
		ACCFMT="$ACCBAL $ACCID (via lockup)"
	fi

	TOTAL_TOTAL=`printf '%s + %s\n' "$TOTAL_TOTAL" "$ACCBAL" | bc`
	if is_own "$ACCID"; then 
		OWN_ACCOUNTS="${OWN_ACCOUNTS}${ACCFMT};"
	elif is_foundation "$ACCID"; then
		FND_ACCOUNTS="${FND_ACCOUNTS}${ACCFMT};"
	else
		DELEG_ACCOUNTS="${DELEG_ACCOUNTS}${ACCFMT};"
	fi
done

print_accts() (
	ACCOUNTS=`printf '%s' "$1" | tr ';' '\n'`
	COUNT=`printf '%s\n' "$ACCOUNTS" | wc -l`
	printf '%s\n' "$ACCOUNTS" | while read ACCBAL ACCID; do
		ACCBALUSD=`printf '%s*%s\n' "$ACCBAL" "$NEAR_PRICE" | bc`
		printf "%14s NEAR  (%14s USD) -- %s\n" "$ACCBAL" "$ACCBALUSD" "$ACCID"
	done
	test $COUNT = 1 && return
	printf '%s\n' "$ACCOUNTS" | ( 
		TOTAL=0; 
		while IFS=' ' read ACCBAL _; do
			TOTAL=`printf '%s + %s\n' "$TOTAL" "$ACCBAL" | bc`
		done
	       	printf '%s\n' "$TOTAL" 
	) | (
		read TOTAL
		TOTAL_USD=`printf '%s*%s\n' "$TOTAL" "$NEAR_PRICE" | bc`
		printf '%14s NEAR  (%14s USD) -- Subtotal across %s accounts\n' "$TOTAL" "$TOTAL_USD" "$COUNT"
	)
)

printf "\nOwn stake, including validator fees:\n"
print_accts "$OWN_ACCOUNTS"

printf "\nNEAR Foundation delegation:\n"
print_accts "$FND_ACCOUNTS"

printf "\nMiscellaneous delegations:\n"
print_accts "$DELEG_ACCOUNTS"

printf "\n"
print_accts "$TOTAL_TOTAL Total across $TOTAL_COUNT account(s)"
