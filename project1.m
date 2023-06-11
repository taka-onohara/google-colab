clc
clear all
close all

f = fred
startdate = '01/01/1994';
enddate = '10/01/2022';

GERrealGDP = fetch(f,'CLVMNACSCAB1GQDE',startdate,enddate)
year1 = GERrealGDP.Data(:,1);
y1 = GERrealGDP.Data(:,2);
JPNrealGDP = fetch(f,'JPNRGDPEXP', startdate,enddate)
year2 = JPNrealGDP.Data(:,1);
y2 = JPNrealGDP.Data(:,2);

%[trend, cycle] = hpfilter(log(y), 1600);
[cycle1, trend1] = qmacro_hpfilter(log(y1), 1600);
[cycle2, trend2] = qmacro_hpfilter(log(y2), 1600);

% compute sd(y) (from detrended series)
ysd1 = std(cycle1)*100;
ysd2 = std(cycle2)*100;

disp(['GERsd: ', num2str(ysd1),'.']); disp(' ')
disp(['JPNsd: ', num2str(ysd2),'.']); disp(' ')
corrcoef = corrcoef(cycle1,cycle2)

figure
plot(year1, cycle1, 'b');
datetick('x', 'yyyy');
xlabel('Time');
title('Detrended log(real GDP) 1994Q1-2022Q4');
grid on;

hold on

plot(year2, cycle2, 'r');
legend GER JPN

hold off

% define function
function [ytilde,tauGDP] = qmacro_hpfilter(y, lam)

T = size(y,1);

% Hodrick-Prescott filter
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauGDP = A\y;

% detrended GDP
ytilde = y-tauGDP;

end