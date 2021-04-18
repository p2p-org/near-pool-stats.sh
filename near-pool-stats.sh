#!/bin/sh

# Usage: ./near-pool-stats.sh <POOL_ACCOUNT_ID>
# E.g. ./near-pool-stats.sh p2p-org.poolv1.near

near_view() (
	contract_accid="$1"
	contract_method="$2"
	contract_args=$(printf '%s' "$3" | base64)

	rpc_params=$(printf '
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
	' "$contract_accid" "$contract_method" "$contract_args")
	curl -s -X POST \
     		-H 'Content-Type: application/json' \
     		-d "$rpc_params" \
     		"$rpc_address" \
			| jq -r ".result.result | implode"
)

get_accounts() (
	page_limit=${page_limit:-100}

	page_index=0
	accounts_json='[]'
	while
		contract_args=$(printf '{"limit": %s, "from_index": %s}' "$page_limit" "$page_index")
		new_accounts_json=$(near_view "$pool_accid" get_accounts "$contract_args")
		new_accounts_count=$(printf '%s' "$new_accounts_json" | jq length)
		page_index=$(( page_index + new_accounts_count ))
		accounts_json=$(printf '%s%s' "$accounts_json" "$new_accounts_json" \
			| jq  -s '.[0]=([.[]]|flatten)|.[0]')
		test "$new_accounts_count" -eq "$page_limit"
	do :; done
	printf '%s' "$accounts_json"
)

get_pool_owner() {
	near_view "$1" get_owner_id | jq -r .
}

is_lockup() {
	printf '%s' "$1" | grep -Eq '^[[:alnum:]]{40}\.lockup\.near$'
}

get_lockup_owner() {
	near_view "$1" get_owner_account_id | jq -r .
}

is_foundation() {
	printf '%s' "$1" | grep -Eq 'nfendowment[[:digit:]]{2}.near'
}

get_near_price() {
	if [ "$near_env" = "mainnet" ]; then
		curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=near&vs_currencies=usd" \
			-H  "accept: application/json" \
			| jq .near.usd
	else
		printf '%s' "0.0000"
	fi
}

is_own() {
	test "$own_accid" = "$1"
}

print_accts() (
	account_ids_and_balances=$(printf '%s' "$1" | tr ';' '\n')
	accounts_count=$(printf '%s\n' "$account_ids_and_balances" | wc -l)
	printf '%s\n' "$account_ids_and_balances" | while read -r balance account_id; do
		if [ "$near_env" = "mainnet" ]; then
			balance_usd=$(printf '%s*%s\n' "$balance" "$near_price" | bc)
			printf "%14s NEAR  (%14s USD) -- %s\n" "$balance" "$balance_usd" "$account_id"
		else
			printf "%14s NEAR -- %s\n" "$balance" "$account_id"
		fi
	done
	test "$accounts_count" -eq 1 && return
	total_balance=$(printf '%s\n' "$account_ids_and_balances" | ( 
		_total_balance=0; 
		while IFS=' ' read -r balance _; do
			_total_balance=$(printf '%s + %s\n' "$_total_balance" "$balance" | bc)
		done
	       	printf '%s\n' "$_total_balance" 
		)
	)
	if [ "$near_env" = "mainnet" ]; then
		total_balance_usd=$(printf '%s*%s\n' "$total_balance" "$near_price" | bc)
		printf '%14s NEAR  (%14s USD) -- Subtotal across %s accounts\n' \
			"$total_balance" "$total_balance_usd" "$accounts_count"
	else
		printf '%14s NEAR -- Subtotal across %s accounts\n' \
			"$total_balance" "$accounts_count"
	fi
)

default_rpc_address() {
	case "$near_env" in
		mainnet) printf '%s' "https://rpc.mainnet.near.org" ;;
		testnet) printf '%s' "https://rpc.testnet.near.org" ;;
		betanet) printf '%s' "https://rpc.betanet.near.org" ;;
	esac
}

pool_accid="$1"
page_limit="${NEAR_RPC_PAGE_LIMIT:-100}"
near_env="${NEAR_ENV:-mainnet}"
rpc_address="${NEAR_RPC_ADDRESS:-$(default_rpc_address)}"

own_accid=$(get_pool_owner "$pool_accid")
all_accounts_json=$(get_accounts)
accounts_json=$(printf '%s' "$all_accounts_json" | jq 'map(select(.staked_balance != "0")) | sort_by(.staked_balance|tonumber) | reverse')
account_ids=$(printf '%s' "$accounts_json" | jq -r '.[]|.account_id')
account_balances=$(printf '%s' "$accounts_json" | jq -r '.[]|.staked_balance' | awk '{ printf "%.4f\n", $1 * 10^-24 }')
all_accounts_count=$(printf '%s' "$all_accounts_json" | jq 'length')
non_empty_count=$(printf '%s' "$accounts_json" | jq 'length')
empty_count=$(( all_accounts_count - non_empty_count ))
near_price=$(get_near_price)

own_accounts=""
fnd_accounts=""
deleg_accounts=""
total_stake=0

for i in $(seq 1 "$non_empty_count"); do
	account_id=$(printf '%s' "$account_ids" | sed -n "${i}p")
	balance=$(printf '%s' "$account_balances" | sed -n "${i}p")
	account_data="$balance $account_id"

	if is_lockup "$account_id"; then
		account_id=$(get_lockup_owner "$account_id")
		account_data="$balance $account_id (via lockup)"
	fi

	total_stake=$(printf '%s + %s\n' "$total_stake" "$balance" | bc)
	if is_own "$account_id"; then 
		own_accounts="${own_accounts}${account_data};"
	elif is_foundation "$account_id"; then
		fnd_accounts="${fnd_accounts}${account_data};"
	else
		deleg_accounts="${deleg_accounts}${account_data};"
	fi
done

printf "Current date: %s\n" "$(date -u)"
test "$near_env" = "mainnet" \
	&& printf "Current NEAR price: %s USD (source: CoinGecko).\n" "$near_price"

printf "\nViewing delegations data for the staking pool %s\n" "$pool_accid"

printf "\nPool owner's stake, including validator fees:\n"
print_accts "$own_accounts"

if [ -n "$fnd_accounts" ]; then
       printf "\nNEAR Foundation delegation:\n"
	print_accts "$fnd_accounts"
fi

if [ -n "$deleg_accounts" ]; then
	printf "\nMiscellaneous delegations:\n"
	print_accts "$deleg_accounts"
fi

printf "\n"
print_accts "$total_stake Total across $non_empty_count non-empty account(s)"
if [ "$near_env" = "mainnet" ]; then
	printf '%45sand %s accounts with zero staked balance\n' ' ' "$empty_count"
else
	printf '%23sand %s accounts with zero staked balance\n' ' ' "$empty_count"
fi
