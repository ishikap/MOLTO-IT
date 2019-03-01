%%--------------------------------------------------------------------------
function [c,ceq] = departure_cons(x,setup)
%%--------------------------------------------------------------------------
%
lc  = 149597870.700e03;
mu  = 132712440018e09;
tc  = sqrt(lc^3/mu);
vc  = lc/tc;
%
%Compute Initial date and Flight Time
%
et0_min    = setup.initial_date;
et0_max    = setup.final_date;
et0_factor = setup.xind + x(4);
et02       = et0_min + (et0_max - et0_min)*et0_factor;
ToF1       = (et02 - setup.et0)/tc;
ToF        = setup.ToF + ToF1+ x(2);
%
% Departure planet position
%
[r0, theta0, v0, psi0] = oe2polar(setup.oe0, ToF1);
%
% Arrival planet position
%
[rf, thetaf,vf, psif] = oe2polar(setup.oe, ToF);
%
% Add Launch velocity
%
%if strcmp(setup.planet1,setup.planet2)
    %
    v1   = v0*cos(psi0) + setup.vinf0*1e3/vc*cos(x(5));
    v2   = v0*sin(psi0) + setup.vinf0*1e3/vc*sin(x(5));
    v0   = norm([v1,v2]);
    psi0 = atan2(v2,v1);
    
% elseif rf > r0
%     
%    v0   = v0 + setup.vinf0*1e3/vc;
%     
% else
%     
%    v0   = v0 - setup.vinf0*1e3/vc;
%     
% end
%
% Ensure thetaf > theta0
%
while( thetaf < theta0 )
   thetaf = thetaf + 2*pi;        
end
%
thetaf = thetaf + 2*pi*setup.n;
%
ee1 = x(1);  
ee2 = 0;
xA  = x(3);
%
thetaA  = xA*(thetaf-theta0) + theta0;
thetaB  = thetaf;
%
if setup.type == 1
    ee2     = x(6);
    xB      = x(7);
    thetaB  = xB*(thetaf-thetaA) + thetaA;
end
%
%------------------------------------------------------------------
% FIRST SPIRAL ARC 
%------------------------------------------------------------------
%
[t1, v, r, theta, psi ] = propagate_spirals_try_mex(v0,r0,theta0,psi0,thetaA,ee1) ; 
%
coast_arc()

if setup.type >0
%
[t2, v, r, ~, psi ] = propagate_spirals_try_mex( v,r, thetaB, psi, thetaf, ee2);
tk = tk + t2;
%
end
%
%------------------------------------------------------------------
% COMPUTE CONSTRAINTS
%------------------------------------------------------------------
%
ToF_spiral = t1 + tk;
%
%c = -x(2);
c = -ToF;
%
if setup.type == 2
    v1 = v(end)*cos(psi(end)) - vf*cos(psif);
    v2 = v(end)*sin(psi(end)) - vf*sin(psif);
    
    c = -setup.vinff_max + sqrt(v1^2+v2^2);
end
%
ceq(1) = (r(end)     - rf)/1;
ceq(2) = (ToF_spiral - ToF)/1;
%
if setup.type == 1
   %
   ceq(3) = (v(end) - vf);
   ceq(4) = (psi(end) - psif);
   %
end
%
if ~isreal(ToF_spiral) || isnan(ToF_spiral)
%
ceq = NaN *ones(size(ceq));
%
end












