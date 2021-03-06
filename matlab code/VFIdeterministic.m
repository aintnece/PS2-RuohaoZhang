clear all
close all
%%%% Set up parameters
alpha = 0.35;
beta = 0.99;
delta = 0.025;
sigma = 2;
pi=[0.977, 0.023; 0.926, 0.074];
A=[0.678;1.1];
%%%% Set up discretized state space
k_min = 0;
k_max = 1.1*(alpha*A(2)/(1/beta-1+delta))^(alpha/(1-alpha))+(1-delta)*(alpha*1.1/(1/beta-1+delta))^(1/(1-alpha));;
num_k = 1000; % number of points in the grid for k

k = linspace(k_min, k_max, num_k);

k_mat = repmat(k', [1 num_k]); % this will be useful in a bit

%%%% Set up consumption and return function
% 1st dim(rows): k today, 2nd dim (cols): k' chosen for tomorrow
consl = 0.678*k_mat .^ alpha + (1 - delta) * k_mat - k_mat'; 
consh = 1.1*k_mat .^ alpha + (1 - delta) * k_mat - k_mat';
retl = consl .^ (1 - sigma) / (1 - sigma);
reth = consh .^ (1 - sigma) / (1 - sigma);
% return function
% negative consumption is not possible -> make it irrelevant by assigning
% it very large negative utility
retl(consl < 0) = -Inf;
reth(consh < 0) = -Inf;
%%%% Iteration
dis = 1; tol = 1e-06; % tolerance for stopping 
v_guess = zeros(2, num_k);
while dis > tol
    % compute the utility value for all possible combinations of k and k':
    value_matl = retl + beta *(pi(2,1)* repmat(v_guess(1,:), [num_k 1])+pi(2,2)*repmat(v_guess(2,:), [num_k 1]));
    value_math = reth + beta *(pi(1,2)* repmat(v_guess(1,:), [num_k 1])+pi(1,1)*repmat(v_guess(2,:), [num_k 1]));
    
    % find the optimal k' for every k:
    [vfnl, pol_indxl] = max(value_matl, [], 2);
    vfnl = vfnl';
    [vfnh, pol_indxh] = max(value_math, [], 2);
    vfnh = vfnh';
    % what is the distance between current guess and value function
    dis = [max(abs(vfnl - v_guess(1,:))) ; max(abs(vfnh - v_guess(2,:)))] ;
    
    % if distance is larger than tolerance, update current guess and
    % continue, otherwise exit the loop
    v_guess= [vfnl;vfnh];
end

gl = k(pol_indxl); 
gh = k(pol_indxh); % policy function
sl=gl-(1-delta)*k;
sh=gh-(1-delta)*k;
subplot(2,1,1);
plot(k,vfnl);
title('Value Function, low state');
xlabel('k');
ylabel('V(k)');
subplot(2,1,2);
plot(k,vfnh);
title('Value Function, high state');
xlabel('k');
ylabel('V(k)');
figure
subplot(2,1,1);
plot(k,gl);hold on;
plot(k,gh);hold off
legend('low state','high state','location','northwest')
title('Policy Function');
xlabel('k');
ylabel('g(k)');
subplot(2,1,2);
plot(k,sl);hold on;
plot(k,sh);hold off;
legend('low state','high state','location','northwest');
title('Saving of K');
xlabel('k');
ylabel('Saving');