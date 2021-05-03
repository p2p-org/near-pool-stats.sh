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
Current date: Mon  3 May 13:56:26 UTC 2021
Current NEAR price: 5.37 USD (source: CoinGecko).
Viewing delegations data for the staking pool p2p-org.poolv1.near

  NEAR balance |    Value in USD | Account ID / Comment
---------------+-----------------+--------------------------------------------------------------------------
     9513.9530 |        51089.93 | p2p-org.near                                                    
---------------+-----------------+--------------------------------------------------------------------------
     9513.9530 |        51089.93 | Pool owner's stake, 0.26% of total stake, accounts: 1           
---------------+-----------------+--------------------------------------------------------------------------
  1024160.3893 |      5499741.29 | nfendowment10.near (lockup)                                     
  1024160.3893 |      5499741.29 | nfendowment09.near (lockup)                                     
  1024160.3893 |      5499741.29 | nfendowment08.near (lockup)                                     
   511589.3868 |      2747235.01 | nfendowment06.near (lockup)                                     
---------------+-----------------+--------------------------------------------------------------------------
  3584070.5547 |     19246458.88 | NEAR Foundation delegation, 99.23% of total stake, accounts: 4  
---------------+-----------------+--------------------------------------------------------------------------
     5471.0538 |        29379.56 | theodore.near                                                   
     3207.9171 |        17226.51 | abackup.near                                                    
     3061.6574 |        16441.10 | skycastle.near (lockup)                                         
     1540.7077 |         8273.60 | cryptnito.near (lockup)                                         
     1313.8813 |         7055.54 | ashpool.near                                                    
      502.6881 |         2699.44 | 911f2f91c454e0db41644fdd2c84325486e17ed1104f9de80e6b0fa401ab0cd3
      458.7426 |         2463.45 | satoshinakamoto.near                                            
      370.5231 |         1989.71 | willypham.near                                                  
      332.4096 |         1785.04 | mikesa.near                                                     
      302.3775 |         1623.77 | vitalyevodin.near                                               
      300.7722 |         1615.15 | petal.near                                                      
      296.8381 |         1594.02 | imperfect_triangle.near                                         
      284.6732 |         1528.70 | loclacenter.near                                                
      159.7113 |          857.65 | seclusionhill.near                                              
      143.5233 |          770.72 | slw.near                                                        
      117.2183 |          629.46 | binaryholder.near                                               
      110.8234 |          595.12 | hieunmben100.near                                               
      100.5880 |          540.16 | 3e4396b143fbf5b0fa77efd6070e9704b105fb1e02c27912a0224e60f90eda53
       70.1709 |          376.82 | vanthong0515.near                                               
       63.2349 |          339.57 | allex.near                                                      
       50.7390 |          272.47 | bytesun.near                                                    
       37.4701 |          201.21 | cryptnito.near                                                  
       36.4128 |          195.54 | comcmipi.near                                                   
       30.0947 |          161.61 | ntt83.near                                                      
       24.9293 |          133.87 | hoathienphong.near                                              
       19.2033 |          103.12 | cunmap.near                                                     
       14.7592 |           79.26 | culbecerazvan.near                                              
       11.0021 |           59.08 | buiducminh2808.near                                             
       10.0287 |           53.85 | hogamvnz.near                                                   
        9.7961 |           52.61 | cda86091de48a9da1db5cb271a2b2949379997381795e5da5c79c2cdf4cdcf86
        8.0630 |           43.30 | brotanec.near                                                   
        4.0183 |           21.58 | ilyar.near                                                      
        1.6384 |            8.80 | nightfox.near                                                   
        1.4042 |            7.54 | ouja8x.near                                                     
        1.1832 |            6.35 | cuenzy.near                                                     
        0.8024 |            4.31 | sam007.near                                                     
        0.7433 |            3.99 | sam2020.near                                                    
        0.7208 |            3.87 | alexb.near                                                      
        0.6369 |            3.42 | 1ae8fa1cbab6187ae90ff72c7d4f006c5d064637de84fe9808e9fa65eed0bb69
        0.5036 |            2.70 | sempertx.near                                                   
        0.0342 |            0.18 | ccb593f13a9ee3eaba2b063265c5960406e1de3758d9d9d9eb87701e5c9dd8ed
---------------+-----------------+--------------------------------------------------------------------------
    18473.6954 |        99203.74 | Miscellaneous delegations, 0.51% of total stake, accounts: 41   
---------------+-----------------+--------------------------------------------------------------------------
  3612058.2031 |     19396752.55 | Total (accounts: 46)                                            

```
## Bonus Ducks!
Generate a PDF report using `enscript` and `ps2pdf`, e.g.
```
./near-pool-stats.sh p2p-org.poolv1.near | enscript -B -f "DejaVuSansMono8" -o - | ps2pdf - near-stats.pdf
```
