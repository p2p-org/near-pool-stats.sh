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
Current date: Wed  5 May 11:12:40 UTC 2021
Current NEAR price: 5.08 USD (source: CoinGecko).
Viewing delegations data for the staking pool p2p-org.poolv1.near

  NEAR balance |    Value in USD | Account ID / Comment
---------------+-----------------+--------------------------------------------------------------------------
     9690.7446 |        49228.98 | p2p-org.near                                                    
               |                 |
     9690.7446 |        49228.98 | 0.27% of total stake, 1 account(s) (pool owner's stake)         
---------------+-----------------+--------------------------------------------------------------------------
  1024601.0124 |      5204973.14 | nfendowment10.near (lockup)                                     
  1024601.0124 |      5204973.14 | nfendowment09.near (lockup)                                     
  1024601.0124 |      5204973.14 | nfendowment08.near (lockup)                                     
   511809.4872 |      2599992.19 | nfendowment06.near (lockup)                                     
               |                 |
  3585612.5244 |     18214911.62 | 99.22% of total stake, 4 account(s) (NEAR Foundation delegation)
---------------+-----------------+--------------------------------------------------------------------------
     5473.4076 |        27804.91 | theodore.near                                                   
     3209.2973 |        16303.23 | abackup.near                                                    
     3062.9746 |        15559.91 | skycastle.near (lockup)                                         
     1541.3706 |         7830.16 | cryptnito.near (lockup)                                         
     1314.4466 |         6677.39 | ashpool.near                                                    
      605.1012 |         3073.91 | 911f2f91c454e0db41644fdd2c84325486e17ed1104f9de80e6b0fa401ab0cd3
      458.9399 |         2331.41 | satoshinakamoto.near                                            
      370.6825 |         1883.07 | willypham.near                                                  
      332.5526 |         1689.37 | mikesa.near                                                     
      302.5076 |         1536.74 | vitalyevodin.near                                               
      300.9016 |         1528.58 | petal.near                                                      
      296.9658 |         1508.59 | imperfect_triangle.near                                         
      284.7957 |         1446.76 | loclacenter.near                                                
      159.7801 |          811.68 | seclusionhill.near                                              
      143.5850 |          729.41 | slw.near                                                        
      117.2687 |          595.72 | binaryholder.near                                               
      110.8710 |          563.22 | hieunmben100.near                                               
      100.6313 |          511.21 | 3e4396b143fbf5b0fa77efd6070e9704b105fb1e02c27912a0224e60f90eda53
       70.2011 |          356.62 | vanthong0515.near                                               
       63.2621 |          321.37 | allex.near                                                      
       50.7609 |          257.87 | bytesun.near                                                    
       37.4862 |          190.43 | cryptnito.near                                                  
       36.4285 |          185.06 | comcmipi.near                                                   
       30.1077 |          152.95 | ntt83.near                                                      
       24.9401 |          126.70 | hoathienphong.near                                              
       19.2116 |           97.59 | cunmap.near                                                     
       14.7655 |           75.01 | culbecerazvan.near                                              
       11.0068 |           55.91 | buiducminh2808.near                                             
       10.0331 |           50.97 | hogamvnz.near                                                   
        9.8003 |           49.79 | cda86091de48a9da1db5cb271a2b2949379997381795e5da5c79c2cdf4cdcf86
        8.0664 |           40.98 | brotanec.near                                                   
        4.0201 |           20.42 | ilyar.near                                                      
        1.6392 |            8.33 | nightfox.near                                                   
        1.4048 |            7.14 | ouja8x.near                                                     
        1.1838 |            6.01 | cuenzy.near                                                     
        0.8028 |            4.08 | sam007.near                                                     
        0.7437 |            3.78 | sam2020.near                                                    
        0.7212 |            3.66 | alexb.near                                                      
        0.6372 |            3.24 | 1ae8fa1cbab6187ae90ff72c7d4f006c5d064637de84fe9808e9fa65eed0bb69
        0.5038 |            2.56 | sempertx.near                                                   
        0.0342 |            0.17 | ccb593f13a9ee3eaba2b063265c5960406e1de3758d9d9d9eb87701e5c9dd8ed
               |                 |
    18583.8408 |        94405.91 | 0.51% of total stake, 41 account(s) (miscellaneous delegations) 
---------------+-----------------+--------------------------------------------------------------------------
  3613887.1098 |     18358546.52 | 100% of total stake, 46 account(s)
```
## Bonus Ducks!
Generate a PDF report using `enscript` and `ps2pdf`, e.g.
```
./near-pool-stats.sh p2p-org.poolv1.near | enscript -B -f "DejaVuSansMono8" -o - | ps2pdf - near-stats.pdf
```
