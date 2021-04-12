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
## Example

```
$ ./near-pool-stats.sh p2p-org.poolv1.near
Current date: Sun 21 Mar 01:05:11 UTC 2021
Current NEAR price: 6.23 USD (source: CoinGecko).

Viewing delegations data for the staking pool p2p-org.poolv1.near

Pool owner's stake, including validator fees:
     4510.0265 NEAR  (    28097.4650 USD) -- p2p-org.near

NEAR Foundation delegation:
  1011585.7519 NEAR  (  6302179.2343 USD) -- nfendowment10.near (via lockup)
  1011585.7519 NEAR  (  6302179.2343 USD) -- nfendowment09.near (via lockup)
  1011585.7519 NEAR  (  6302179.2343 USD) -- nfendowment08.near (via lockup)
   505308.0942 NEAR  (  3148069.4268 USD) -- nfendowment06.near (via lockup)
  3540065.3499 NEAR  ( 22054607.1298 USD) -- Subtotal across 4 accounts

Miscellaneous delegations:
     4121.4977 NEAR  (    25676.9306 USD) -- theodore.near
     3116.0029 NEAR  (    19412.6980 USD) -- cryptnito.near (via lockup)
     1199.9961 NEAR  (     7475.9757 USD) -- alias007.near
     1004.0786 NEAR  (     6255.4096 USD) -- straderb.near
      727.1055 NEAR  (     4529.8672 USD) -- ashpool.near
      453.1101 NEAR  (     2822.8759 USD) -- satoshinakamoto.near
      405.9224 NEAR  (     2528.8965 USD) -- 911f2f91c454e0db41644fdd2c84325486e17ed1104f9de80e6b0fa401ab0cd3
      390.7484 NEAR  (     2434.3625 USD) -- willypham.near
      328.3283 NEAR  (     2045.4853 USD) -- mikesa.near
      306.8349 NEAR  (     1911.5814 USD) -- davirain.near
      281.1780 NEAR  (     1751.7389 USD) -- loclacenter.near
      237.4006 NEAR  (     1479.0057 USD) -- lyhung1654.near
      157.7504 NEAR  (      982.7849 USD) -- seclusionhill.near
      141.7611 NEAR  (      883.1716 USD) -- slw.near
      115.7791 NEAR  (      721.3037 USD) -- binaryholder.near
      110.7286 NEAR  (      689.8391 USD) -- hieunmben100.near
      100.7677 NEAR  (      627.7827 USD) -- 3e4396b143fbf5b0fa77efd6070e9704b105fb1e02c27912a0224e60f90eda53
       50.1161 NEAR  (      312.2233 USD) -- bytesun.near
       14.5780 NEAR  (       90.8209 USD) -- culbecerazvan.near
        9.6758 NEAR  (       60.2802 USD) -- cda86091de48a9da1db5cb271a2b2949379997381795e5da5c79c2cdf4cdcf86
        4.0388 NEAR  (       25.1617 USD) -- d54b364dbc181a3f82d6065a2d34f3cc1bc841659c3dc56005acd4bf767b9f4d
        0.7342 NEAR  (        4.5740 USD) -- sam2020.near
        0.7120 NEAR  (        4.4357 USD) -- alexb.near
        0.0000 NEAR  (             0 USD) -- db5577.near
    13278.8453 NEAR  (    82727.2062 USD) -- Subtotal across 24 accounts

  3557854.2217 NEAR  ( 22165431.8011 USD) -- Total across 29 account(s)
```
## Bonus Ducks!
Generate a PDF report using `enscript` and `ps2pdf`, e.g.
```
./near-pool-stats.sh p2p-org.poolv1.near | enscript -B -f "DejaVuSansMono8" -o - | ps2pdf - near-stats.pdf
```
