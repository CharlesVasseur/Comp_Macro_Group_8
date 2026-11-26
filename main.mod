var
C_H // Consumption of Hand-to-Mouth Households
C_R // Consumption of Ricardian Households
C // Total Consumption
Y // Output
I // Investment 
N_H // Labor of Hand-to-Mouth Households
N_R // Labor of Ricardian Households
N // Total Labor
K // Capital
G // Government spending
T // Taxes
Profits // Profits
Lambda_H // Lagrange multiplier for HTM households
Lambda_R // Lagrange multiplier for Ricardian households
B // Bonds
W // wage 
A // Total factor productivity
q // price of bonds
;

varexo 
eps_A // Shock to TFP
eps_G // Shock to government spending 
eps_tau // Tax cut shock (debt-financed)
;

parameters
beta // time discount factor
delta // depreciation rate
alpha // capital share in production
v // share of HTM households
chi // disutility of labor
eta // curvature of labor disutility
G_bar // steady state government spending
rho_A // persistence of TFP shock
rho_G // persistence of government spending shock
sigma_A // standard deviation of TFP shock
sigma_G // standard deviation of government spending shock
sigma_tau // standard deviation of Tax shock
phi_T // quickness to adjust taxes to debt
phi_G // share of spending increase that is financed by taxes on impact
B_bar // steady state bonds
T_bar // steady state taxes
;

beta    = 0.96; 
delta   = 0.1; 
alpha   = 1/3; 
v       = 0; 
chi     = 10.625;  
G_bar   = 0.1023; 
eta     = 1;
B_bar   = 0; 
T_bar   = G_bar + (1-beta)*B_bar;   
phi_T   = 0.8;    // must satisfy 1-q < phi < 1+q
phi_G   = 0.1;   
rho_A   = 0.9;
rho_G   = 0.66;   
sigma_A = 0.01;
sigma_G = 0.01;
sigma_tau = 0.003; 

model; 
//Model Equations

// HTM HH Block 
// FOC w.r.t.C
C_H = 1/Lambda_H; 

// FOC w.r.t.N
chi*N_H^eta = W*Lambda_H;

// BC of HTM HH:  
C_H = W*N_H - T;

// R HH Block 
// FOC w.r.t.C
C_R = 1/Lambda_R; 

// FOC w.r.t.N
chi*N_R^eta = W*Lambda_R;

// FOC w.r.t. B(+1)
q = beta*Lambda_R(+1)/Lambda_R;

// BC of R HH:
C_R + q*B/(1-v)= W*N_R + Profits/(1-v) + B(-1)/(1-v) - T;

// Total Consumption 
C = v*C_H + (1-v)*C_R;

// Firm Block 

// Production function
Y = A*K(-1)^alpha*N^(1-alpha);

// Labor
N = v*N_H + (1-v)*N_R;

// Capital accumulation equation
K = (1-delta)*K(-1) + I;

// FOC w.r.t. K
Lambda_R = beta*Lambda_R(+1)*(alpha*A(+1)*K^(alpha-1)*N(+1)^(1-alpha) + 1-delta);

// FOC w.r.t. N
W = (1-alpha)*Y/N;

// Profits 
Profits = Y - W*N - I;

// Exogenous processes
log(A) = rho_A*log(A(-1)) + eps_A;

log(G/G_bar) = rho_G*log(G(-1)/G_bar) + eps_G;

T = T_bar + phi_T*(B(-1)-B_bar) + phi_G*(G-G_bar) - eps_tau; // Fiscal Rule configured from Gali, Lopez-Salido & Valles (2007) 
// Government Block 

//Government BC
G + B(-1) = T + q*B;

end;

steady_state_model;
A = 1;
G = G_bar;
B = B_bar;
q = beta;
T = T_bar;

// Guided by Slides 5 & 6, and checked using AI.  
// capital per worker from the capital Euler equation
  k_hourly  = (alpha/(1/beta - 1 + delta))^(1/(1-alpha)); // capital per hour worked
  y_hourly = k_hourly^alpha; // output per hour worked
  W     = (1-alpha)*y_hourly; 
  net_product = y_hourly - delta*k_hourly; // net output per hour worked
  prof_hourly  = alpha*y_hourly - delta*k_hourly; // profit per hour worked

  // labor: quadratic root (hold only for eta = 1)
  N_H = (chi*T + sqrt((chi*T)^2 + 4*chi*W^2)) / (2*chi*W); // Take positive root as hours must be positive 
  c0  = prof_hourly*v*N_H/(1-v) + (1-q)*B/(1-v) - T; // 
  N_R = (-chi*c0 + sqrt((chi*c0)^2 + 4*chi*net_product*W)) / (2*chi*net_product); // Take positive root as hours must be positive

  N  = v*N_H + (1-v)*N_R;
  K  = k_hourly*N;
  Y  = A*K^alpha*N^(1-alpha);
  I  = delta*K;
  Profits = Y - W*N - I;
  C_H = W*N_H - T;
  C_R = W*N_R + Profits/(1-v) + (1-q)*B/(1-v) - T;
  C   = v*C_H + (1-v)*C_R;
  Lambda_H = 1/C_H;
  Lambda_R = 1/C_R;

end;

// Calculates the steady state values. 
steady; 

// Produces residuals for each equation, which should be close to zero if the model is correctly specified and the steady state is computed correctly.
resid; 

// Checks the Blanchard-Kahn conditions for the existence and uniqueness of a stable solution to the model. 
check; 

// Checks for missing or redundant equations. 
model_diagnostics; 

shocks; 
  var eps_A; stderr sigma_A;
  var eps_G; stderr sigma_G;
  var eps_tau; stderr sigma_tau;
end;

// Used AI to create scenario analysis for different values of v (share of HTM households) and to compute the corresponding impulse response functions (IRFs) and multipliers.
// low HTM share: Data from US 1983-2004 Source: (Bilbiie, Meier, and Müller, 2006). 
v = 0.35;
steady; 
check; 
stoch_simul(order=1, irf=40, nograph)
    C C_H C_R Y K N_R N_H W T B G;
irf_low = oo_.irfs;

// High HTM share: Data from US 1957-1979 Source: (Bilbiie, Meier, and Müller, 2006).
v = 0.51;
steady;
check;
stoch_simul(order=1, irf=40, nograph)
    C C_H C_R Y K N_R N_H W T B G;
irf_high = oo_.irfs;

// Used AI to compute the multipliers for both scenarios (low and high HTM share). 
// Multipliers
// Impact multipliers: extra Y per extra unit of G 
mult_low  = irf_low.Y_eps_G(1)  / irf_low.G_eps_G(1)
mult_high = irf_high.Y_eps_G(1) / irf_high.G_eps_G(1)

// Cumulative multipliers: discounted sum of extra Y over discounted sum of extra G over 40 years
disc = 0.96.^(0:39); // assumes beta = 0.96 
cum_low  = sum(disc .* irf_low.Y_eps_G)  / sum(disc .* irf_low.G_eps_G)
cum_high = sum(disc .* irf_high.Y_eps_G) / sum(disc .* irf_high.G_eps_G)

// Tax multipliers (impact): change in Y per unit of tax cut
taxmult_low  = irf_low.Y_eps_tau(1)  / -irf_low.T_eps_tau(1)
taxmult_high = irf_high.Y_eps_tau(1) / -irf_high.T_eps_tau(1)

// Used AI to write the plotting code (comparison figures and one figure per variable).
// Figures 
// Spending shock: Y and C, low vs high v
figure;
subplot(1,2,1); plot(irf_low.Y_eps_G); hold on; plot(irf_high.Y_eps_G, '--'); title('Y');
legend('v = 0.35', 'v = 0.51');
subplot(1,2,2); plot(irf_low.C_eps_G); hold on; plot(irf_high.C_eps_G, '--'); title('C');
saveas(gcf, 'figures/irf_Gov_spending_shock.png');

// Tax cut shock: Y and C, low vs high v
figure;
subplot(1,2,1); plot(irf_low.Y_eps_tau); hold on; plot(irf_high.Y_eps_tau, '--'); title('Y');
legend('v = 0.35', 'v = 0.51');
subplot(1,2,2); plot(irf_low.C_eps_tau); hold on; plot(irf_high.C_eps_tau, '--'); title('C');
saveas(gcf, 'figures/irf_tax_cut.png');

// One figure per variable, both scenarios overlaid
vars = {'C','C_H','C_R','Y','K','N_R','N_H','W','T','B','G'};
for i = 1:numel(vars); figure; plot(irf_low.([vars{i} '_eps_G'])); hold on; plot(irf_high.([vars{i} '_eps_G']), '--'); title(vars{i}); legend('v = 0.35', 'v = 0.51'); saveas(gcf, ['figures/irf_' vars{i} '_spending.png']); close; end
for i = 1:numel(vars); figure; plot(irf_low.([vars{i} '_eps_tau'])); hold on; plot(irf_high.([vars{i} '_eps_tau']), '--'); title(vars{i}); legend('v = 0.35', 'v = 0.51'); saveas(gcf, ['figures/irf_' vars{i} '_taxcut.png']); close; end

// Used AI to write the robustness check code 
// Robustness check: greater tax financing of government spending
// Baseline phi_G = 0.1 (10% of extra spending tax-financed on impact). Tests whether conclusions hold when phi_G = 1 (all extra spending is tax-financed immediately)
phi_G = 1;

v = 0.35;
steady;
stoch_simul(order=1, irf=40, nograph)
    C C_H C_R Y K N_R N_H W T B G;
irf_low_tax = oo_.irfs;

v = 0.51;
steady;
stoch_simul(order=1, irf=40, nograph)
    C C_H C_R Y K N_R N_H W T B G;
irf_high_tax = oo_.irfs;

phi_G = 0.1;  // restore baseline

// Spending multipliers under tax financing
mult_low_tax  = irf_low_tax.Y_eps_G(1)  / irf_low_tax.G_eps_G(1)
mult_high_tax = irf_high_tax.Y_eps_G(1) / irf_high_tax.G_eps_G(1)
cum_low_tax   = sum(disc .* irf_low_tax.Y_eps_G)  / sum(disc .* irf_low_tax.G_eps_G)
cum_high_tax  = sum(disc .* irf_high_tax.Y_eps_G) / sum(disc .* irf_high_tax.G_eps_G)