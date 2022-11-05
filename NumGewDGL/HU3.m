%% HU3 Aufgabe H2 - a) Verfahren von Heun

clearvars
hmax = 0.1;                 % maximale Zeitschrittweite
hmin = 0.0001;              % minimale Zeitschrittweite
hh = flip(hmin:hmin:hmax);  % Zeitschwrittgrößen von hmax bis 0.0001

cc = 0;                     % norm fehlervektor initialisieren

% Problemdefinition
f = @(t,y) [y(2); -pi^2*y(1)]; y0=[1; 0];
yex = @(t) [cos(pi*t); -pi*sin(pi*t)];
%yy = y0; y=y0;

% Iteration über kleiner werdendes h
for h = hh(2:end)
    
    T = 1;          % Endzeit
    tt = 0:h:T;     % Zeitgitter
    y0=[1; 0];      % Reset der Startwerte/ Vektoren
    yy = y0; y=y0;
    
    % num. Approximation mit Heun
    for t=tt(2:end)
        y = y + h*(f(t,y)/2+(f(t+h,y+h*f(t,y)))/2); % Verfahren von Heun (explizite Trapezmethode)
        yy = [yy,y];
    end
    % exakte Lösung ausgewertet am Zeitgitter
    yyex=yex(tt);
    % norm. Fehler der num. Approximation
    c = norm((yyex(1,:)-yy(1,:)),'Inf');
    cc = [cc,c];
end

% Konvergenz plot
loglog(hh,cc)
title('Konvergenzverhalten - von Heun')
xlabel('h')
ylabel('|| y-y_h ||')
grid on


%% HU3 Aufgabe H2 - b) impliziter Euler

clearvars
hmax = 0.1;                 % maximale Zeitschrittweite
hmin = 0.001;              % minimale Zeitschrittweite
hh = flip(hmin:hmin*5:hmax);  % Zeitschwrittgrößen von hmax bis 0.0001

cc = 0;                     % norm fehlervektor initialisieren

% Problemdefinition
f = @(t,y) [y(2); -pi^2*y(1)]; y0=[1; 0];
yex = @(t) [cos(pi*t); -pi*sin(pi*t)];
%yy = y0; y=y0;

% Iteration über kleiner werdendes h
for h = hh(2:end)
    
    T = 1;          % Endzeit
    tt = 0:h:T;     % Zeitgitter
    y0=[1; 0];      % Reset der Startwerte/ Vektoren
    yy = y0; y=y0;
    
    % num. Approximation mit imp. Euler
    for t=tt(2:end)
        fun = @(y1) [y-y1-h*(f(t+h,y1))]; % impliziter Euler
        [y,fval]=fsolve(fun,y0);
        yy = [yy,y];
    end
    % exakte Lösung ausgewertet am Zeitgitter
    yyex=yex(tt);
    % norm. Fehler der num. Approximation
    c = norm((yyex(1,:)-yy(1,:)),'Inf');
    cc = [cc,c];
end

% Konvergenz plot
loglog(hh,cc)
title('Konvergenzverhalten - impl. Euler')
xlabel('h')
ylabel('|| y-y_h ||')
grid on