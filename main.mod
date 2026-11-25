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
beta // time discount
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

beta    = 0.96; // Time dicount factor
delta   = 0.1; // Depreciation rate
alpha   = 1/3; // Share of GDP from capital
v       = 0; // Share of HTM households
chi     = 10.625;   // Disutility of labor
G_bar = 0.1023; // Steady state government spending
eta     = 1; // Elasticity of labor disutility
B_bar   = 0; // Steady state bonds
T_bar   = G_bar + (1-beta)*B_bar; // Steady state taxes
phi_T   = 0.8; // Quickness to adjust taxes to debt
phi_G   = 0.1; // Share of additional spending that is financed through taxes
rho_A   = 0.9; // Persistence of TFP shock
rho_G   = 0.66; // Persisistence of government spending shock
sigma_A = 0.01; // Standard deviation of TFP shock
sigma_G = 0.01; // Standard deviation of government spending shock
sigma_tau = 0.003; // Standard deviation of Tax shock

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

T = T_bar + phi_T*(B(-1)-B_bar) + phi_G*(G-G_bar) - eps_tau;
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

steady; 
resid; 
check; 

shocks; 
  var eps_A; stderr sigma_A;
  var eps_G; stderr sigma_G;
  var eps_tau; stderr sigma_tau;
end;

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

// Multipliers
// Impact multipliers: extra Y per extra unit of G
mult_low  = irf_low.Y_eps_G(1)  / irf_low.G_eps_G(1)
mult_high = irf_high.Y_eps_G(1) / irf_high.G_eps_G(1)

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