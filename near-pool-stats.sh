#!/bin/sh

die() {
       echo "$*" 1>&2
       exit 1
}

ACCOUNT_POOL="$1"
ACCOUNTS_OWN="$2"
ACCOUNTS_BLACKLIST="$3"

get_accounts() {
	# This requires a modified version of `near-cli` that outputs JSON.
	# Also it must be based on the latest upstream version to avoid the 
	# "new version available" message in the end.
	near view "$ACCOUNT_POOL" get_accounts \
		'{"limit": 100, "from_index": 0}' \
		| sed -e '1d'
}

near_price() {
	curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=near&vs_currencies=usd" \
	        -H  "accept: application/json" \
		| jq .near.usd
}

is_blacklisted() {
	ACCT_MATCH=`printf '%s' "$ACCOUNTS_BLACKLIST" | tr ' ' '\n' | grep "$1"`
	test -n "$ACCT_MATCH"
}
is_own() {
	ACCT_MATCH=`printf '%s' "$ACCOUNTS_OWN" | grep "$1"`
	test -n "$ACCT_MATCH"
}

ACCOUNTS_JSON=$(get_accounts)
accounts() {
       printf '%s' "$ACCOUNTS_JSON"
}

ACCOUNTS_JSON=`accounts | jq 'sort_by(.staked_balance|tonumber) | reverse'`
ACCOUNT_IDS=`accounts | jq -r '.[]|.account_id'`
ACCOUNT_BALANCES=`accounts | jq -r '.[]|.staked_balance' | awk '{ printf "%.4f\n", $1 * 10^-24 }')`
ACCOUNT_COUNT=`accounts | jq 'length'`
NEAR_PRICE=`near_price`

printf "\nCurrent date: %s\n" "`date -u`"
printf "Current NEAR price: %s USD (source: CoinGecko).\n" "$NEAR_PRICE"

printf "\nViewing delegations data for the staking pool "$ACCOUNT_POOL"\n"

printf "\nAll delegations (excluding Foundation):\n"

DELEG_COUNT=0
TOTAL_BALANCE=0
OWN_BALANCE=0
for i in `seq 1 $ACCOUNT_COUNT`; do
	ACCID=`printf '%s' "$ACCOUNT_IDS" | sed -n ${i}p`
	ACCBAL=`printf '%s' "$ACCOUNT_BALANCES" | sed -n ${i}p`

	if is_blacklisted "$ACCID"; then continue;
	elif is_own "$ACCID"; then 
		OWN_BALANCE=`printf '%s + %s\n' "$OWN_BALANCE" "$ACCBAL" | bc`
		continue
	fi

	TOTAL_BALANCE=`printf '%s + %s\n' "$TOTAL_BALANCE" "$ACCBAL" | bc`
	DELEG_COUNT=`expr $DELEG_COUNT + 1`
	ACCBALUSD=`printf '%s*%s\n' "$ACCBAL" "$NEAR_PRICE" | bc`
	printf "%13s NEAR  (%13s USD) -- %s\n" "$ACCBAL" "$ACCBALUSD" "$ACCID"
done

TOTAL_USD=`printf '%s*%s\n' "$TOTAL_BALANCE" "$NEAR_PRICE" | bc`
printf "\nTotal delegated across %d accounts:\n %13s NEAR (%13s USD)\n" "$DELEG_COUNT" "$TOTAL_BALANCE" "$TOTAL_USD"

OWN_USD=`printf '%s*%s\n' "$OWN_BALANCE" "$NEAR_PRICE" | bc`
printf "\nThe staking pool is managed by $ACCOUNTS_OWN\n"
printf "Own stake, including validator fees collected:\n %13s NEAR (%13s USD) -- $ACCOUNTS_OWN\n" "$OWN_BALANCE" "$OWN_USD"

