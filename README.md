#### Data Cleaning
1. "0A\_Convert\_Data.ipynb": Clean SDC Global Public Finance sample and M\&A sample. Clean demographics and geographic datasets. Clean the California bond issue sample.
2. "0C\_SNL\_CB\_Convert\_Data.ipynb": Clean commercial bank M\&A and deposit data.
3. "0D\_Census\_Convert\_Data.ipynb": Clean Census data on local government finances.

#### Sample Construction
1. "1B\_Issuer\_Underwriter\_Geo.ipynb": Generate treatment-control matched samples for bond issues and for local government finances. Generate samples for the placebo tests of cross-market M\&As and withdrawn M\&As.
2. "1B\_CB\_Placebo.ipynb": Generate the sample for the placebo test of (purely) commercial bank M\&As.

#### Tables and Figures
1. "1C\_Table\_SummStats.do": Summary statistics.
2. "1D\_Table\_SpreadMainResults.do", "1D\_Figure\_SpreadMainResults.do", "1D\_Table\_SpreadHeteroEffects.do", "1D\_Figure\_EffectByUse.do": Effects of M\&As on the underwriting spread and cross-sectional heterogeneities of the effects.
3. "1E\_Table\_YieldResults.do", "1E\_Figure\_YieldResults.do": Effects of M\&As on the offering yields and other offering terms.
4. "1F\_Table\_ExamineEfficiency.do", "1F\_Figure\_ExamineEfficiency.do", "1F\_Table\_PredictOtherFees.do", "1F\_Table\_NetCost.do": Investigations over the efficiency gains from M\&As.
5. "1G\_Table\_SpreadIV.do": Estimating the elasticity of the underwriting spread to HHI.
6. "1G\_Table\_SpreadPlacebo.do": Placebo tests to rule out alternative explanations.
7. "1G\_Table\_SpreadRobustness.do": Robustness tests.
8. "1I\_Table\_GovFin.do", "1I\_Proc\_GovFin.do": Effects of M\&As on local government finances.