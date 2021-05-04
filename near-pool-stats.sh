#!/bin/sh

# Usage: ./near-pool-stats.sh <POOL_ID>
# E.g. ./near-pool-stats.sh p2p-org.poolv1.near

die() {
	printf '%s\n' "$1" 1>&2
	exit 1;
}

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

print_separator() {
	if [ "$near_env" = "mainnet" ]; then
		printf '%14s +%16s + %73s\n' | tr ' ' '-'
	else
		printf '%14s + %73s\n' | tr ' ' '-'
	fi
}

print_empty() {
	if [ "$near_env" = "mainnet" ]; then
		printf '%14s |%16s |\n'
	else
		printf '%14s |\n'
	fi
}

print_balance() (
	balance="$1"
	comment="$2"
	if [ "$near_env" = "mainnet" ]; then
		balance_usd=$(printf '%s %s' "$balance" "$near_price" | awk '{ printf "%0.2f", $1 * $2 }')
		printf "%14s |%16s | %-64s\n" "$balance" "$balance_usd" "$comment"
	else
		printf "%14s | %-64s\n" "$balance" "$comment"
	fi
)

print_accts() (
	comment="$1"
	account_ids_and_balances=$(printf '%s' "$2" | tr ';' '\n')
	accounts_count=$(printf '%s\n' "$account_ids_and_balances" | wc -l)
	printf '%s\n' "$account_ids_and_balances" | while read -r balance account_id; do
		print_balance "$balance" "$account_id"
	done
	total_balance=$(printf '%s\n' "$account_ids_and_balances" | ( 
		_total_balance=0; 
		while IFS=' ' read -r balance _; do
			_total_balance=$(printf '%s + %s\n' "$_total_balance" "$balance" | bc)
		done
	       	printf '%s\n' "$_total_balance" 
		)
	)
	total_percent=$(printf '%s %s' "$total_balance" "$total_stake" | awk '{ printf "%0.2f", $1 / $2 * 100 }')
	print_empty
	print_balance "$total_balance" "$comment, $total_percent% of total stake, accounts: $accounts_count"
)

default_rpc_address() {
	case "$near_env" in
		mainnet) printf '%s' "https://rpc.mainnet.near.org" ;;
		testnet) printf '%s' "https://rpc.testnet.near.org" ;;
		betanet) printf '%s' "https://rpc.betanet.near.org" ;;
	esac
}

print_hdr() {
	if [ "$near_env" = "mainnet" ]; then
		printf '%14s |%16s | %s\n' "NEAR balance" "Value in USD" "Account ID / Comment"
	else
		printf '%14s | %s\n' "NEAR balance" "Account ID / Comment"
	fi
}

pool_accid="$1"
page_limit="${NEAR_RPC_PAGE_LIMIT:-100}"
near_env="${NEAR_ENV:-mainnet}"
rpc_address="${NEAR_RPC_ADDRESS:-$(default_rpc_address)}"
usage="Usage: $0 <pool_id>
    pool_id: The account ID of the staking pool"

test -z "$pool_accid" && die "$0: no staking pool specified"

own_accid=$(get_pool_owner "$pool_accid")
all_accounts_json=$(get_accounts)
accounts_json=$(printf '%s' "$all_accounts_json" | jq 'map(select(.staked_balance != "0")) | sort_by(.staked_balance|tonumber) | reverse')
account_ids=$(printf '%s' "$accounts_json" | jq -r '.[]|.account_id')
account_balances=$(printf '%s' "$accounts_json" | jq -r '.[]|.staked_balance' | awk '{ printf "%0.4f\n", $1 * 10^-24 }')
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
		account_data="$balance $account_id (lockup)"
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

printf "Viewing delegations data for the staking pool %s\n\n" "$pool_accid"

print_hdr
print_separator

print_accts "Pool owner's stake" "$own_accounts"

if [ -n "$fnd_accounts" ]; then
	print_separator
	print_accts "NEAR Foundation delegation" "$fnd_accounts"
fi

if [ -n "$deleg_accounts" ]; then
	print_separator
	print_accts "Miscellaneous delegations" "$deleg_accounts"
fi

print_separator
print_balance "$total_stake" "Total (accounts: $non_empty_count)"
printf '\n'
