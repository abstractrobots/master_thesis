temp1 = XYZ_actual.Data;
temp1_x = temp1(1,1,:);
temp1_y = temp1(2,1,:);
temp1_z = temp1(3,1,:);

temp2 = XYZ_referans.Data;
temp2_x = temp2(1,1,:);
temp2_y = temp2(2,1,:);
temp2_z = temp2(3,1,:);

for i=1:numel(temp1_x)
    X_a(i) = temp1_x(1,1,i);
    Y_a(i) = temp1_y(1,1,i);
    Z_a(i) = temp1_z(1,1,i);
end

for i=1:numel(temp2_x)
    X_r(i) = temp2_x(1,1,i);
    Y_r(i) = temp2_y(1,1,i);
    Z_r(i) = temp2_z(1,1,i);
end

XYZ_a = [X_a; Y_a; Z_a]';

XYZ_r = [X_r; Y_r; Z_r]';

figure 
plot3(X_a, Y_a, Z_a)
hold on
plot3(X_r, Y_r, Z_r)

%% 

temp3 = waypoints;
temp3_x = temp3(1,:);
temp3_y = temp3(2,:);
temp3_z = temp3(3,:);



len1 = numel(wp_joint_space.Time);
wp_js_time = wp_joint_space.Time;
for i=1:len1
    for j=1:5
    wp_js(i,j) = wp_joint_space.Data(j,1,i);
    end
end





