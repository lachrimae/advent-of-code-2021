Initially it seemed to me that the biggest challenge with this problem was the fact that the amount of storage to contain the whole polymer would blow up beyond any reasonable amount of RAM or disk space. This stack-based approach ensured that the maximum amount of data stored at any time would never go beyond about a kilobyte. However, the number of CPU cycles required remains exponential, so I wasn't getting results fast enough. 

After looking online at discussion around this problem, I realized that the linear sequencing of the polymer was a red herring. A bucketing approach like the solution for day 6 works fine here.  

I kept my stack-based Rust prototype, because finding the linear-space, exponential-time solution was fun. But the real implementation here is the Haskell buckets approach.

The Haskell implementation is the real
