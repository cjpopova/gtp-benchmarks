scripts
===

Racket code:

- `count-chaperones.rkt` : collects low-level performance details
- `make-configurations.rkt` : creates the `2**N` configurations for a benchmark
- `modulegraph.rkt` : builds module-dependence graphs
- `type-info.rkt` : collects type annotations
- `copy-configuration.rkt` : creates one configuration (not user-friendly)
- `make-typed-configurations.rkt` : creates fully-typed configurations for all benchmarks
- `analyze-contract-random-generate.rkt` : test contract-random-generate on fully typed configs
- `more-analysis.rkt` : send the results from `analyze-contract-random-generate.rkt` to postgres

Other:

- `count-chaperones.patch` patch that adds C-level variables to count chaperones.
  This patch probably will not apply automatically. Good luck.
  Originally from <https://www.cs.umd.edu/~sstrickl/chaperones/index.html>
- `gtp-a1.sql` : analyze results from `analyze-contract-random-generate.rkt` in postgres

`analyze-contract-random-generate.rkt` analysis results:
```


```
