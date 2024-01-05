%% Problem 1.1
N = 1000;
X = 2*(rand(N, 3)-0.5);

D = 1*(X *[1 5 -2]'>0);

     
W = 2*rand(1, 3) - 1;
E = [];
P = [];
num_epoch = 1000;
for epoch = 1:num_epoch           % train
  W = DeltaSGD(W, X, D);
  V = W*X'; 
  Y = Sigmoid(V);
  E = [E norm(Y-D')];
  P = [P sum((Y>0.5)~=D')];
      
  end
figure(1), plot(E);
figure(2), plot(P);

%% Problem 1.2

N = 1000;
X = 2*(rand(N, 3)-0.5);

D = 1*(X.^2 *[1 1 1]' > 1);    % x1^2 + x2^2 + x^3 > 1


W = 2*rand(1, 3) - 1;
E = [];
P = [];
num_epoch = 1000;
for epoch = 1:num_epoch           % train
  W = DeltaSGD(W, X, D);
  V = W*X'; 
  Y = Sigmoid(V);
  E = [E norm(Y-D')];
  P = [P sum((Y>0.5)~=D')];
      
  end
figure(1), plot(E);
figure(2), plot(P);

%% Problem 2.1
N = 1000;

X = 2*(rand(N, 3)-0.5);
D = 1*( [X(:,1).^2 abs(X(:,2)) X(:,3)] * [1 2 1]' > 1);
sum(D)/length(D)

num_neuron = 200;      
W1 = 2*rand(num_neuron , 3) - 1;
W2 = 2*rand(1, h_num_neuron) - 1;

E = [];
P = [];
num_epoch = 100;
for epoch = 1 : num_epoch           % train
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

%% Problem 2.2
N = 1000;

X = 2*(rand(N, 3)-0.5);
D = 1*( [exp(X(:,1)) X(:,2) X(:,3)] * [1 1 2]' > 1);
sum(D)/length(D)

num_neuron = 3;      
W1 = 2*rand(num_neuron, 3) - 1;
W2 = 2*rand(1, num_neuron) - 1;

E = [];
P = [];
num_epoch = 1000;
for epoch = 1:num_epoch          % train
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