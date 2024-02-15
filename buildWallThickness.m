clc; clear; close all;

interior_contour_m = csvread('MOC_engine_contour_m.csv');

chamber_thickness = 0.15; %[in]
    chamber_thickness_m = chamber_thickness/39.3701; % [m]
throat_thickness = 0.2; %[in]
    throat_thickness_m = throat_thickness/39.3701; % [m]
nozzle_thickness = 0.1; %[in]
    nozzle_thickness_m = nozzle_thickness/39.3701; % [m]

chamber_end_ind = 0;
chamber_min_contour_m = interior_contour_m(:,2)-interior_contour_m(1,2);
for i = 1:length(interior_contour_m(:,2))
    if(chamber_min_contour_m(i) >= 0)
        chamber_end_ind = i;
    end
end
chamber_curve_end_ind = 2300; % HARDCODED

throat_buffer = 0.25; %[in]
    throat_buffer_m = throat_buffer/39.3701; %[m[

[~,throat_start_index] = min(interior_contour_m(:,2));

throat_end_index = 0;
x_start = interior_contour_m(throat_start_index,1);
for i = throat_start_index:length(interior_contour_m(:,1))
    if(interior_contour_m(i,1)-x_start <= throat_buffer_m)
        throat_end_index = i;
    end
end

nozzle_end_index = length(interior_contour_m(:,1));

chamber_thickness_matrix = [linspace(chamber_thickness_m,chamber_thickness_m,chamber_end_ind),...
    linspace(chamber_thickness_m,0.212/39.3701,chamber_curve_end_ind-chamber_end_ind)];
throat_thickness_matrix = [linspace(0.212/39.3701,throat_thickness_m,throat_start_index-chamber_curve_end_ind), ...
    linspace(throat_thickness_m,throat_thickness_m,throat_end_index-throat_start_index)];
nozzle_thickness_matrix = linspace(throat_thickness_m,nozzle_thickness_m,nozzle_end_index-throat_end_index);

wall_thickness_matrix = [chamber_thickness_matrix,throat_thickness_matrix,nozzle_thickness_matrix];

for i = 1:length(interior_contour_m(:,2))
    exterior_contour_m(i) = interior_contour_m(i,2)+wall_thickness_matrix(i);
end

wallThicknessFig = figure('Name','Wall Thickness');
subplot(2,1,1);
hold on
plot(interior_contour_m(:,1)*39.3701,interior_contour_m(:,2)*39.3701,'k');
plot(interior_contour_m(:,1)*39.3701,exterior_contour_m*39.3701,'k');
grid on
axis equal
xlim([interior_contour_m(1,1)*39.3701 interior_contour_m(end,1)*39.3701]);ylim([0 2*max(interior_contour_m(:,2))*39.3701])
title('Nitron I Wall Thickness'); xlabel('$L_{e}$ $[in]$'); ylabel('$R$ $[in]$');
subplot(2,1,2)
plot(interior_contour_m(:,1)*39.3701,wall_thickness_matrix*39.3701)
title('Wall Thickness vs. Engine Length'); xlabel('$L_{e}$ $[in]$'); ylabel('$t_{wall}$ $[in]$');
grid on
xlim([interior_contour_m(1,1)*39.3701 interior_contour_m(end,1)*39.3701]);ylim([0 inf])

saveas(wallThicknessFig,'wallThickness','png');

x_data = interior_contour_m(:,1);
y_data = exterior_contour_m';
z_data  = zeros(length(interior_contour_m(:,1)),1);
exterior_contour = [x_data,y_data,z_data];



csvwrite('MOC_exterior_contour.txt',exterior_contour)
csvwrite('MOC_interior_contour.txt',interior_contour_m)