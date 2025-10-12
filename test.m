% quick test
vs = rand(3,10000);
A = [1 0 0;0 -1 0;0 0 1];
tic;
for i = 1:1000
    tmp = A*vs;
end
toc;
tic;
for i = 1:1000
    tmp = [vs(1,:);-vs(2,:);vs(3,:)];
end
toc;