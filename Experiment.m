
%% Here is a toy example. 
rng('default');
addpath(genpath(pwd));

n = [2500, 2500];  % number of data points from each manifold
D = 50;  % the ambient dimension 
d = 2;   % the intrinsic dimenison
rotation = [0, pi/2]; % rotate randomly generated horizontal manifolds by an angle. 
tau = 0.05; 
noise_type = 'uniform'; 

data = zeros([sum(n) D]); labels = zeros([sum(n) 1]);

% For each manifold
for j = 1:length(n)

  % Generate rotation
  c = cos(rotation(j));
  s = sin(rotation(j));
  G = eye(D);
  G(1:(d+1),1:(d+1)) = [ c 0 s; 
                         0 1 0
                        -s 0 c];
 

  % Generate noiseless, standardized data
  thisData = zeros([n(j) D]);
  thisData(:,1:d) = -0.5 + rand([n(j) 2]);

  % Pollute standardized data with noise
  switch noise_type
    case 'gaussian'
      thisData = thisData + normrnd(0,tau/sqrt(D-d),size(thisData));
    case 'uniform'
      thisData = thisData + sqrt(3)*tau/sqrt(D-d)*(2*rand(size(thisData))-1);
  end

  % Rotate polluted data
  thisData = thisData * G;

  % Place data in right locations in output.
  row1 = 0 + sum(n(1:(j-1))) + 1;
  row2 = sum(n(1:j));
  data(row1:row2,:) = thisData;
  labels(row1:row2) = j;
end

plot3(data(1:n(1),1),data(1:n(1),2),data(1:n(1),3),'.')
hold on 
plot3(data(n(1)+1:n(1)+n(2),1),data(n(1)+1:n(1)+n(2),2),data(n(1)+1:n(1)+n(2),3),'.')
hold off

%% Here is where you run the SVD code. 
parallel = 0;    
EstDimopts = struct('NumberOfTrials',3,'verbose',0,'MAXDIM',size(data,2),'MAXAMBDIM',size(data,2),'Ptwise',0,'PtIdxs',0,'NetsOpts',[],'UseSmoothedS',0,'EnlargeScales',0,'Deltas',[],'KeepV',0,'kNN',[],'AllPtsFast',0,'DownSample',1,'RandomizedSVDThres',inf);
[d_est,noise_margin] = EstDim_MSVD(data', parallel, EstDimopts);
d_est; % this should be equal to d
tau_est = sqrt(D-d)*noise_margin; % this should be equal to tau. 