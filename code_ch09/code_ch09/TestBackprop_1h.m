clear all
           

N = 100;
X = [ randn(N,1) randn(N,1)];

D = 1*((exp(X(:,1)) + exp(X(:,2))) > 2);


% X = [ 0 0 1;
%       0 1 1;
%       1 0 1;
%       1 1 1;
%     ];
% 
% D = [ 0
%       1
%       1
%       0
%     ];
      
W1 = 2*rand(5, 2) - 1;
W2 = 2*rand(1, 5) - 1;

E = [];
P = [];
for epoch = 1:1000           % train
  [W1 W2] = Backprop_1h(W1, W2, X, D);
   V1 = W1*X';
   Y1 = Sigmoid(V1);
   V = W2*Y1;
   YY = Sigmoid(V);
  E = [E norm(YY'-D)];
  P = [P sum((YY>0.5)~=D')];
  end

figure(1), plot(E);
figure(2), plot(P);

% N = 4;                        % inference
% Y = zeros(size(D));
%  for k = 1:N
%    x  = X(k, :)';
%    v1 = W1*x;
%    y1 = Sigmoid(v1);
%    v  = W2*y1;
%    y  = Sigmoid(v);
%    Y(k) = y;
%  end

%   E = [E norm(Y-D)];
% YY
% [Y D]
