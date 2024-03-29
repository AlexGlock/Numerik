%% Aufgabe H4 aus Hausübung HU4
% Code von Alexander Glock
clearvars

% Vorgabe der Matrix Dimension des AWP := (n_awp+1)x(n_awp+1)
n_awp=5;
% Anfangswertproblem generieren: 
% --> make_task1(n) = System aus Aufgabenteil (I)
% --> make_task2(n) = System aus Aufgabenteil (II)
[A_awp,y0,t0,T]=make_task1(n_awp); %make_task2(n)

% ODE der Form:
f = @(t,y) (-1)*A_awp*y;

% Verfahrensauswahl mit make_RK(sel):
% sel: 1=Heun a)   2=Gauss-2 b)   3=imp. Trapez c) 
[A,b,g]=make_RK(3);

%[yhom,t] = yhomogen(A_awp,y0,n_awp,t0,T,10)
%[tt, yy] = myRK(y0,f,t0,T,10,A,b,g)
%yhom(:,1)
%plot(t,yhom)

% experimentelle Ordnungsermittlung mit Plot:
test = convPlot(y0,f,t0,T,A,b,g,A_awp,n_awp);

% schriftliche Ergebnisse ganz unten 
function [A_awp,y0,t0,T] = make_task1(n)
    % A Diagonale erstellen - Dim n+1
    d0 = 2 + zeros(1, n+1);
    d0(1)=0;d0(n+1)=0;
    % A Nebendiagonalen erstellen - Dim n
    d1 = -1 + zeros(1, n);
    d1(1)=0;d1(n)=0;
    % Systemmatrix A generieren - Dim (n+1)x(n+1)
    A_awp = n^2*(diag(d0)+diag(d1,-1)+diag(d1,1));
    
    % Startvektor y0 generieren - Dim (n+1)
    y0=zeros(1,n+1)';
    jj=(1:1:n+1);
    for j=jj(1:end)
        if (n+1)/4 < j && j < 3*(n+1)/4 
            y0(j)=sin((j-(n+1)/4)*2*pi/(n+1));
        end
    end
    t0=0;
    T=0.1;
end
function [A_awp,y0,t0,T] = make_task2(n)
    % A Diagonale erstellen - Dim n+1
    d0 = ones(1, n+1);
    % A Nebendiagonalen erstellen - Dim n+1
    d1 = -1 + zeros(1, n);
    % Systemmatrix A generieren - Dim (n+1)x(n+1)
    A_awp = n*(diag(d0)+diag(d1,-1));
    A_awp(1,n+1)=n*(-1);
    
    % Startvektor y0 generieren - Dim (n+1)
    y0=zeros(1,n+1)';
    jj=(1:1:n+1);
    for j=jj(1:end)
        if (n+1)/4 < j && j < 3*(n+1)/4 
            y0(j)=sin((j-(n+1)/4)*2*pi/(n+1));
        end
    end
    t0=0;
    T=2;
end
function [A,b,g] = make_RK(sel)
    switch sel
        case 3 % imp. Trapez
            A =[0 0; 1/2 2/2];  
            b =[1/2 1/2]';
            g =[0 1]';
        case 2 % Gauss-2
            A =[1/4 1/4-sqrt(3)/6; 1/4+sqrt(3)/6 1/4];  
            b =[1/2 1/2]';
            g =[1/2-sqrt(3)/6 1/2+sqrt(3)/6]';
        otherwise % Heun
            A =[0 0; 1 0];  
            b =[1/2 1/2]';
            g =[0 1]';
    end
end
function Y = Yex(E,vec,tt)
    Y = zeros(length(E),length(tt));
    for i=1:1:length(tt)
        ti=tt(i);
        Yi=zeros(1,length(E))';
    
        for val=(1:1:length(E))
            Yi= Yi +vec(:,val)*exp(E(val)*ti);
        end
    end
end
function test = convPlot(y0,f,t0,T,A,b,g,A_awp,n_awp)
        h0=@(h) 1;
        h1=@(h) h;

        Amat=(-1)*A_awp
      
        hmax = T/100;                    % maximale Zeitschrittweite
        hmin = T/10000;                  % minimale Zeitschrittweite
        hh = flip(hmin:10*hmin:hmax);    % Zeitschwrittgrößen von hmax bis hmin
        cc = 0;                          % norm fehlervektor initialisieren

    for h=hh(2:end)
        n_t=round(T/h);
        % Approximation mit RKV
        [tt, yy] = myRK(y0,f,t0,T,n_t,A,b,g);
        % "exakte" Lösung des DGL Systems zu tt berechnen:
        [yhom, ~]=yhomogen(Amat,y0,n_awp,t0,T,n_t)


        % norm. Fehler des RKV
        c = norm((yhom(1,:)-yy(:,1)),'Inf') % norm(yhom-yy,'Inf'); %
        cc = [cc,c];%[cc,norm(yhom-yy)];%
    end
    
    % Konvergenz plot
    loglog(hh,cc,'-r',hh,h0(hh),'--b',hh,h1(hh),'--g')
    title('Numerical error vs Stepwidth in double log scale')
    xlabel('size of h')
    ylabel('Numerical error || y-y_h ||')
    legend('Num error','konst 1','lin. konv')
    grid on

    test='fertig';
end

% Funktion zur Berechnung der analytischen, homogenen Lösung

%--------------------------------------------------------------------------

function [yhom,t] = yhomogen(Amat,y0,n,t0,T,n_t)

    % Berechnung der Schrittweitte h
    h = (T-t0)/n_t;

    % Berechnung der Eigenwerte und -vektoren zu Amat
    [eigvec,eigval] = eig(Amat);
    
    % Erstelle yhom leer und t 
    t       = t0:h:T;
    yhom    = zeros(n_t,n+1);
    
    % Führe Berechnung fort, solange geometrische Vielfalt 
    % der Eigenvektoren passt
    if det(eigvec) ~= 0
        
        % Bestimmung der Konstanten zur homogenen Lösung
        cons = ones(1,n+1);
        F = @(cons) (cons .*eigvec * ones(n+1,1) - y0);
        cons = fsolve(F,cons,optimoptions('fsolve','Display','none'));
    
        % Multiplikation der Konstanten mit Eigenvektoren
        vec_hom = cons.*eigvec;

       % Berechne homogene Lösung
        for i=1:1:n_t+1 

            ti = t(1,i);
            solvevec = zeros(n+1,1);
            for val=1:1:n+1
                solvevec = solvevec + vec_hom(:,val) * exp(eigval(val,val)*ti);
            end
            yhom(i,:) = solvevec';   

        end
    
    end

end

%% Ergebnis:
% Mit den gegebenen Anfangswertproblemen besitzen alle drei Verfahren die
% Konvergenzordnung 0, da sie nicht konvergieren und damit einen konstanten
% Fehler zur analytischen Lösung vorweisen der niemals verschwindet.

% Die impliziten Verfahren (b & c) sind für alle Schrittweiten h stabil.
% Das äußert sich im Konvergenzplot durch einen gleichmäßigen Verlauf des numerischen
% Fehlers mit endlicher Steigung. Beim expliziten Verfahren (a) entwickelt
% sich ab einem h von ungefähr 10^(-2) eine Instabilität. Zu sehen ist das am
% numerische Fehler der an diesem Punkt im Konvergenzplot rasant ansteigt und sehr groß wird.



