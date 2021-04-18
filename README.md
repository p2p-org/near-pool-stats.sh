# near-pool-stats.sh

A POSIX shell script to output delegations stats of a NEAR staking pool in a human-readable way.

## Prerequisites

- a POSIX-compliant shell (tested on `bash`, `dash`, and `ksh`)
- some POSIX utilities: `grep`, `awk`, `sed`, `bc`
- `jq`
- `curl`

## Usage
```
$ ./near-pool-stats.sh <STAKING_POOL_ACCOUNT_ID>
```

## Environment variables
- `NEAR_ENV` (default: `mainnet`): determines the default RPC address and whether to calculate USD balances. If set to `mainnet`, `testnet` or `betanet` and `NEAR_RPC_ADDRESS` is not set, uses the corresponding official RPC address by default. If set to anything other than `mainnet`, disables conversion to USD.
- `NEAR_RPC_ADDRESS` (default: `https://rpc.mainnet.near.org`): the RPC node address to use.
- `NEAR_RPC_PAGE_LIMIT` (default: 100): how many delegator accounts to request from the RPC at a time. The maximum depends on the RPC node configuration. The default value should work well with the official RPC.

## Example

```
$ ./near-pool-stats.sh p2p-org.poolv1.near
Current date: Sun 18 Apr 11:20:12 UTC 2021
Current NEAR price: 4.82 USD (source: CoinGecko).

Viewing delegations data for the staking pool p2p-org.poolv1.near

Pool owner's stake, including validator fees:
     7760.9980 NEAR  (    37408.0103 USD) -- p2p-org.near

NEAR Foundation delegation:
  1019778.1658 NEAR  (  4915330.7591 USD) -- nfendowment10.near (via lockup)
  1019778.1658 NEAR  (  4915330.7591 USD) -- nfendowment09.near (via lockup)
  1019778.1658 NEAR  (  4915330.7591 USD) -- nfendowment08.near (via lockup)
   509400.3751 NEAR  (  2455309.8079 USD) -- nfendowment06.near (via lockup)
  3568734.8725 NEAR  ( 17201302.0854 USD) -- Subtotal across 4 accounts

Miscellaneous delegations:
     5447.6440 NEAR  (    26257.6440 USD) -- theodore.near
     1534.1153 NEAR  (     7394.4357 USD) -- cryptnito.near (via lockup)
      732.9940 NEAR  (     3533.0310 USD) -- ashpool.near
      500.5371 NEAR  (     2412.5888 USD) -- 911f2f91c454e0db41644fdd2c84325486e17ed1104f9de80e6b0fa401ab0cd3
      456.7797 NEAR  (     2201.6781 USD) -- satoshinakamoto.near
      393.9129 NEAR  (     1898.6601 USD) -- willypham.near
      330.9873 NEAR  (     1595.3587 USD) -- mikesa.near
      301.0837 NEAR  (     1451.2234 USD) -- vitalyevodin.near
      295.5680 NEAR  (     1424.6377 USD) -- imperfect_triangle.near
      283.4551 NEAR  (     1366.2535 USD) -- loclacenter.near
      159.0280 NEAR  (      766.5149 USD) -- seclusionhill.near
      142.9092 NEAR  (      688.8223 USD) -- slw.near
      116.7167 NEAR  (      562.5744 USD) -- binaryholder.near
      100.1576 NEAR  (      482.7596 USD) -- 3e4396b143fbf5b0fa77efd6070e9704b105fb1e02c27912a0224e60f90eda53
       50.5219 NEAR  (      243.5155 USD) -- bytesun.near
       37.3098 NEAR  (      179.8332 USD) -- cryptnito.near
       36.2570 NEAR  (      174.7587 USD) -- comcmipi.near
       25.0501 NEAR  (      120.7414 USD) -- raekoin.near
       24.8227 NEAR  (      119.6454 USD) -- hoathienphong.near
       14.6960 NEAR  (       70.8347 USD) -- culbecerazvan.near
        9.7541 NEAR  (       47.0147 USD) -- cda86091de48a9da1db5cb271a2b2949379997381795e5da5c79c2cdf4cdcf86
        8.0285 NEAR  (       38.6973 USD) -- brotanec.near
        4.0011 NEAR  (       19.2853 USD) -- ilyar.near
        1.1782 NEAR  (        5.6789 USD) -- cuenzy.near
        0.7402 NEAR  (        3.5677 USD) -- sam2020.near
        0.7178 NEAR  (        3.4597 USD) -- alexb.near
        0.5014 NEAR  (        2.4167 USD) -- sempertx.near
    11009.4674 NEAR  (    53065.6328 USD) -- Subtotal across 27 accounts

  3587505.3379 NEAR  ( 17291775.7286 USD) -- Total across 32 non-empty account(s)
                                             and 3 accounts with zero staked balance
```
## Bonus Ducks!
Generate a PDF report using `enscript` and `ps2pdf`, e.g.
```
./near-pool-stats.sh p2p-org.poolv1.near | enscript -B -f "DejaVuSansMono8" -o - | ps2pdf - near-stats.pdf
```
