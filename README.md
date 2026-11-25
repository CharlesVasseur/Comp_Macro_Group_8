# Computational Macroeconomics - Group 8
### *How do hand-to-mouth households change fiscal multipliers?*

A simple two-household-type model: Ricardian households and hand-to-mouth households, with a common labour market and simple fiscal policy.

Compare government-spending impulse responses when the share of hand-to-mouth households is low versus high. Focus on aggregate consumption and output.

### Running the model
- **Software used for verification:** GNU Octave 11.3.0 and Dynare 7.2. These versions are not pinned in the model files.
- **File to run:** `main.mod`. From the repository root in Octave, run `dynare main.mod`.
- **Results:** computes the steady state and a first-order stochastic simulation, including 40-period impulse responses for consumption (aggregate and by household type), output, investment, capital, labor, wages, taxes, bonds, and government spending.

### Our Parameters
- Discount Rate:                                   $\beta         = 0.96$ *based on Dong, Liu & Wang (2023), and Galí, López-Salido & Vallés (2004)*
- Depreciation of Capital:                         $\delta        = 0.1$ *based on Dong, Liu & Wang (2023), and Galí, López-Salido & Vallés (2004)*
- Share of GDP from Capital:                       $\alpha        = 1/3$ *based on Galí, López-Salido & Vallés (2004)*
- Share of hand-to-mouth Households:               $v             = 0.35 or 0.51$ *based on Bilbiie, Meier, and Müller (2006)* 
- Disutility of Labor:                             $\chi          = 10.3$ *calibrated so that N = ⅓*
- Elasticity of Labor to Consumption:              $\eta          = 1$ *from class (Sessions 5 & 6)*
- Steady State Government Spending:                $\bar{G}       = 0.11$ *based on Leeper, Traum & Walker (2017)*
- Steady State Bonds                               $\bar{B}       = 0$ *based on Galí, López-Salido & Vallés (2004)*
- Quickness to adjust Taxes to Debt:               $\phi_T        = 0.76$ *based on Galí, López-Salido & Vallés (2004)*
- Proportion of additional Government Spending financed through Taxes: $\phi_G = 0.1$ *based on Galí, López-Salido & Vallés (2004)*
- Persistence of TFP Shock:                        $\rho_A        = 0.9$ *from class (Sessions 5 & 6)*
- Persistence of Government Spending Shock:        $\rho_G        = 0.66$ *based on Galí, López-Salido & Vallés (2004)*
- Standard Deviation of TFP Shock:                 $\sigma_A      = 0.01$ *from class (Sessions 5 & 6)*
- Standard Deviation of Government Spending Shock: $\sigma_G      = 0.01$ *based on Galí, López-Salido & Vallés (2004)*
- Standard Deviation of Tax Shock:                 $\sigma_{\tau} = 0.01$ *based on Leeper, Plante & Traum (2009)*

### Sources
| Paper | Author | Date |
| -------- | -------- | ------ |
| *Limited asset markets participation, monetary policy and (inverted) aggregate demand logic* | **Florin O. Bilbiie** | May 2008 |
| *Consumption, Income, and Interest Rates: Reinterpreting the Time Series Evidence* | **John Y. Campbell and N. Gregory Mankiw** | 1989 |
| *Understanding the Effects of Government Spending on Consumption* | **Jordi Galí, J. David López-Salido, Javier Vallés** | April 2004 |
| *Dynamics of Fiscal Financing in the United States* | **Eric M. Leeper, Michael Plante & Nora Traum** | July 2009 |
| *Clearing Up the Fiscal Multiplier Morass* | **Eric M. Leeper, Nora Traum & Todd B. Walker** | March 2017 |
| *Turbulent Business Cycles* | **Ding Dong, Zheng Liu & Penfei Wang** | February 2023 |
