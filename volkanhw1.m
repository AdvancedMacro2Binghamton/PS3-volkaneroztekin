% PROGRAM NAME: ps4huggett.m
clear, clc

% PARAMETERS
beta = .9932; %discount factor 
sigma = 1.5; % coefficient of risk aversion
b = 0.5; % replacement ratio (unemployment benefits)
y_s = [1, b]; % endowment in employment states
PI = [.97 .03; .5 .5]; % transition matrix


% ASSET VECTOR
a_lo = -2; %lower bound of grid points
a_hi = 5;%upper bound of grid points
num_a = 10;

a = linspace(a_lo, a_hi, num_a); % asset (row) vector

% INITIAL GUESS FOR q
q_min = 0.98;
q_max = 1;
q_guess = (q_min + q_max) / 2;

% ITERATE OVER ASSET PRICES
aggsav = 1 ;
while abs(aggsav) >= 0.01 ;
    
    % CURRENT RETURN (UTILITY) FUNCTION
    cons = bsxfun(@minus, a', q_guess * a);
    cons = bsxfun(@plus, cons, permute(y_s, [1 3 2]));
    ret = (cons .^ (1-sigma)) ./ (1 - sigma); % current period utility
    
    % INITIAL VALUE FUNCTION GUESS
    v_guess = zeros(2, num_a);
    
    % VALUE FUNCTION ITERATION
    v_tol = 1;
    while v_tol >.0001;
        % CONSTRUCT RETURN + EXPECTED CONTINUATION VALUE
        if y==y_s(1) %for employed endowment
          v=ret+beta*((PI(1,1)*repmat(1*permute(v_guess,[3 2 1]),[num_a 1])
+PI(1,2)*repmat(b*permute(v_guess,[3 2 1]),[num_a 1]))       
        else
         %when y==y_s(2) for unemployed case
          v=ret+beta*((PI(2,1)*repmat(1*permute(v_guess,[3 2 1]),[num_a 1])
+PI(2,2)*repmat(b*permute(v_guess,[3 2 1]),[num_a 1]))
        end 
            % CHOOSE HIGHEST VALUE (ASSOCIATED WITH a' CHOICE)
        [valmax,pol_indx]=max(v,[],2)
        
        v_tol=max(abs(valmax(:,:,1)'-v_guess(1,:)));max(abs(valmax(:,:,2)'-v_guess(2,:)))]
        
        v_guess=[valmax(:,:,1)';valmax(:,:,2)']
        
  
    end;
    
    % KEEP DECSISION RULE
    pol_fn = a(pol_indx);
    
    % SET UP INITITAL DISTRIBUTION
    Mu=ones(1,num_a)
    
    % ITERATE OVER DISTRIBUTIONS
    [emp_ind, a_ind, mass] = find(Mu > 0); % find non-zero indices
    
    MuNew = zeros(size(Mu));
    for ii = 1:length(emp_ind)
        apr_ind = pol_indx(emp_ind(ii), a_ind(ii)); % which a prime does the policy fn prescribe?
        MuNew(:, apr_ind) = MuNew(:, apr_ind) + ... % which mass of households goes to which exogenous state?
            (PI(emp_ind(ii), :) * mass)';
    end
 
        
end

plot(a,v_guess)
figure, plot(a,pol_fn)