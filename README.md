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
Current date: Tue  4 May 10:02:16 UTC 2021
Current NEAR price: 5.21 USD (source: CoinGecko).
Viewing delegations data for the staking pool p2p-org.poolv1.near

  NEAR balance |    Value in USD | Account ID / Comment
---------------+-----------------+--------------------------------------------------------------------------
     9572.8436 |        49874.52 | p2p-org.near                                                    
               |                 |
     9572.8436 |        49874.52 | Pool owner's stake, 0.26% of total stake, accounts: 1           
---------------+-----------------+--------------------------------------------------------------------------
  1024307.1884 |      5336640.45 | nfendowment10.near (lockup)                                     
  1024307.1884 |      5336640.45 | nfendowment09.near (lockup)                                     
  1024307.1884 |      5336640.45 | nfendowment08.near (lockup)                                     
   511662.7160 |      2665762.75 | nfendowment06.near (lockup)                                     
               |                 |
  3584584.2812 |     18675684.11 | NEAR Foundation delegation, 99.22% of total stake, accounts: 4  
---------------+-----------------+--------------------------------------------------------------------------
     5471.8380 |        28508.28 | theodore.near                                                   
     3208.3769 |        16715.64 | abackup.near                                                    
     3062.0963 |        15953.52 | skycastle.near (lockup)                                         
     1540.9286 |         8028.24 | cryptnito.near (lockup)                                         
     1314.0696 |         6846.30 | ashpool.near                                                    
      502.7601 |         2619.38 | 911f2f91c454e0db41644fdd2c84325486e17ed1104f9de80e6b0fa401ab0cd3
      458.8083 |         2390.39 | satoshinakamoto.near                                            
      370.5762 |         1930.70 | willypham.near                                                  
      332.4573 |         1732.10 | mikesa.near                                                     
      302.4208 |         1575.61 | vitalyevodin.near                                               
      300.8153 |         1567.25 | petal.near                                                      
      296.8806 |         1546.75 | imperfect_triangle.near                                         
      284.7140 |         1483.36 | loclacenter.near                                                
      159.7342 |          832.22 | seclusionhill.near                                              
      143.5438 |          747.86 | slw.near                                                        
      117.2351 |          610.79 | binaryholder.near                                               
      110.8392 |          577.47 | hieunmben100.near                                               
      100.6024 |          524.14 | 3e4396b143fbf5b0fa77efd6070e9704b105fb1e02c27912a0224e60f90eda53
       70.1810 |          365.64 | vanthong0515.near                                               
       63.2439 |          329.50 | allex.near                                                      
       50.7463 |          264.39 | bytesun.near                                                    
       37.4755 |          195.25 | cryptnito.near                                                  
       36.4180 |          189.74 | comcmipi.near                                                   
       30.0991 |          156.82 | ntt83.near                                                      
       24.9329 |          129.90 | hoathienphong.near                                              
       19.2061 |          100.06 | cunmap.near                                                     
       14.7613 |           76.91 | culbecerazvan.near                                              
       11.0037 |           57.33 | buiducminh2808.near                                             
       10.0302 |           52.26 | hogamvnz.near                                                   
        9.7975 |           51.04 | cda86091de48a9da1db5cb271a2b2949379997381795e5da5c79c2cdf4cdcf86
        8.0641 |           42.01 | brotanec.near                                                   
        4.0189 |           20.94 | ilyar.near                                                      
        1.6387 |            8.54 | nightfox.near                                                   
        1.4044 |            7.32 | ouja8x.near                                                     
        1.1834 |            6.17 | cuenzy.near                                                     
        0.8025 |            4.18 | sam007.near                                                     
        0.7435 |            3.87 | sam2020.near                                                    
        0.7209 |            3.76 | alexb.near                                                      
        0.6370 |            3.32 | 1ae8fa1cbab6187ae90ff72c7d4f006c5d064637de84fe9808e9fa65eed0bb69
        0.5037 |            2.62 | sempertx.near                                                   
        0.0342 |            0.18 | ccb593f13a9ee3eaba2b063265c5960406e1de3758d9d9d9eb87701e5c9dd8ed
               |                 |
    18476.3435 |        96261.75 | Miscellaneous delegations, 0.51% of total stake, accounts: 41   
---------------+-----------------+--------------------------------------------------------------------------
  3612633.4683 |     18821820.37 | Total (accounts: 46)
```
## Bonus Ducks!
Generate a PDF report using `enscript` and `ps2pdf`, e.g.
```
./near-pool-stats.sh p2p-org.poolv1.near | enscript -B -f "DejaVuSansMono8" -o - | ps2pdf - near-stats.pdf
```
