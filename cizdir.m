windowSize = 25; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

filtered_tepki_kuvveti = filter(b,a,tepki_kuvveti);
plot(tout,filtered_tepki_kuvveti)

for i=1:numel(uygulanan_tork(1,1,:))
    q1_tork(i) = uygulanan_tork(1,1,i);
    q2_tork(i) = uygulanan_tork(2,1,i);
    q3_tork(i) = uygulanan_tork(3,1,i);
    q4_tork(i) = uygulanan_tork(4,1,i);
    q5_tork(i) = uygulanan_tork(5,1,i);
end

plot(tout,q1_tork,tout,q2_tork,tout,q3_tork,tout,q4_tork,tout,q5_tork)