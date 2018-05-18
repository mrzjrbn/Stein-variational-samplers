%% Conditional diffusion setup
%
% By Gianluca Detommaso -- 18/05/2018
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%% Model         

% Set length of the state 
model.n = 100;

% Parameter/obs ratio
model.ratio = 5;

% Length of the forward map
model.m = model.n/model.ratio;

% Final time
model.T = 1;

% Discrete times
model.h = model.T/model.n;
model.t = model.h:model.h:model.T; 

% Scale of potential
model.beta = 10;

% Forward map
model.F = @(u) forward_solve(u, model);
  
% True x
wn           = randn(model.n,1);
model.x_true = [sqrt(model.h)*wn(1); zeros(model.n-1,1)];
for j = 1:model.n-1
    model.x_true(j+1) = model.x_true(j) + sqrt(model.h)*wn(j+1);
end

% Calculate true solution
model.sol_true = [model.x_true(1); zeros(model.n-1, 1)];

for j = 2:model.n
    model.sol_true(j) = model.sol_true(j-1)*( 1 + model.beta*( 1-model.sol_true(j-1)^2 ) ...
        / ( 1+model.sol_true(j-1)^2 ) * model.h ) + (model.x_true(j) - model.x_true(j-1));   
end


%% Prior

% Prior mean
prior.m0      = zeros(model.n,1);
% Prior covariance matrix
prior.C0      = zeros(model.n);
for i = 1:model.n
    prior.C0(i,:) = min(model.t(i), model.t);
end
% Prior precision matrix
prior.C0i     = prior.C0^(-1);
% Square root of prior covariance matrix
prior.C0sqrt  = real(sqrtm(prior.C0));
% Square root of prior precision matrix
prior.C0isqrt = real(sqrtm(prior.C0i));


%% Observation

% Number of independent observations
obs.nobs    = 1;
% Noise standard deviation
obs.std     = 0.1;
% Nose variance
obs.std2    = obs.std^2;
% Noise
obs.noise   = obs.std*randn(model.m, obs.nobs); 

% Observations
obs.y = forward_solve(model.x_true , model) + obs.noise;
% Observation times
obs.t = model.t(model.ratio:model.ratio:end);