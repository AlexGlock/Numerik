%% numdgl Hausübung 6 Aufgabe H3 - Blowup
% Code von Alexander Glock und Luisa Emrich
clearvars

% Ergebnis:
% Die Schrittweitensteuerung aus der Vorlesung führt bei dem gegebenen
% Anfangswertproblem zu einer sehr starken Verkleinerung von h für T >= 1 und dadurch zu
% einer unendlichen Rechendauer. Zu sehen ist dieses Verhalten
% auch schon bei kleineren Lösungszeiträumen (T~0.99). Wobei die Schrittweite
% am Ende des Lösungsintervalls bereits beginnt schnell gegen null zu
% streben.
% Dieser Effekt ist auf die Beschaffenheit der DGL und ihrer Lösungsfunktion zurück zu
% führen, da die Lösung ab T=1 unendlich anwächst. Aufgrund dieses
% rasanten Wachstums entsteht eine große Abweichung bei der Berechnung der
% numerischen Zeitschritte mit unterschiedlichen Ordnungen.
% Dadurch werden die Schrittweiten des DOPRI-Solvers immer
% kleiner bis der Zeitschritt so klein geworden ist, dass er mit der
% Maschinengenauigkeit des Rechners nicht mehr aufgelöst werden kann und dadurch 
% kein zeitlicher Fortschritt mit dem berechnen eines neuen (y)Schrittes gemacht wird.
% Schließlich fährt sich der Algorithmus fest und es entsteht eine unendliche Rechnung.
% Bei anderen Solvern wird dieser Fehlerfall durch eine maximale
% Iterationszahl als Abbruchbedingung abgefangen.

[f, S] = create_DES();
y0=1;
t0=0;

T=0.99;

% lösen mit DOPRI Solver
fac=0.84;
facmin=1/4;
facmax=4;
tol=10^(-5);
h=10^(-2);
[t,y, hh] = myDOPRI(y0,f,t0,T,tol,facmin,facmax,fac,h);

% Plot der Lösung 
plot(t,y)
title('DOPRI Lösung für diff(y) = y^2')
xlabel('Zeit t in Sekunden')
ylabel('y')

% Plot der Schrittweitenentwicklung
figure
plot(t,hh(2:end))
title('DOPRI Schrittweitentwicklung')
xlabel('Zeit t in Sekunden')
ylabel('Schrittweite h')


%--------------------------------------------------------------------------
%--------------------------- DOPRI - solver -------------------------------

function [t,y,hh] = myDOPRI(y0,f,t0,T,tol,facmin,facmax,fac,h)

    DOPRI_f_calls=0;
    % DOPRI Verfahrensdefinition:
    A= [0 0 0 0 0 0 0; 1/5 0 0 0 0 0 0; 3/40 9/40 0 0 0 0 0; 
        44/45 -56/15 32/9 0 0 0 0; 19372/6561 -25360/2187 64448/6561 -212/729 0 0 0;
        9017/3128 -355/33 46732/5247 49/176 -5103/18656 0 0;
        35/384 0 500/1113 125/192 -2187/6784 11/84 0];
    gamma=[0 1/5 3/10 4/5 8/9 1 1]';
    beta1=[35/384 0 500/1113 125/192 -2187/6784 11/84 0]';
    beta2=[5179/57600 0 7571/16695 393/640 -92097/339200 187/2100 1/40]';
    
    % DOPRI order
    p=5;        
    
    %init the arrays for t,y and index
    t=t0;
    y=y0;
    hh=h;
    curStep=2; % step 1 = y0
    
    %Main loop for repeatedly evaluating a single step of the RKV
    %Repeat a single step of the RKV as many times as required
    while t(end)<=T
    
     % calculate y step(s)
     [y_od4, y_od5, DOPRI_f_calls] = BEgeneralRKStep(t(curStep-1),y(:,curStep-1),A,gamma,beta1,beta2,h,f,DOPRI_f_calls);
    
     % calculate estimated error
     y_err=norm(y_od4-y_od5,"inf");
     delta = fac*(tol/y_err)^(1/p);
     if y_err<=tol
         % calculate corresponding time
         t_new= t(curStep-1)+h;
         % append to solution
         y(:,curStep)=y_od5;
         t(curStep)=t_new;
         % update curStep index
         curStep=curStep+1;
         hh(curStep)=h;
     end
    
     % update h for next step
     h = h*min([facmax, max([facmin, delta])])
    end
    
    % fehler ausgeben
    %DOPRI_error=norm(y0-y(:,end),'inf')
    DOPRI_f_calls
end

%--------------------------------------------------------------------------
%-------------- bearbeitete Hilfsfunktion aus myRK ------------------------

function [y1i ,yi, fkt_calls] = BEgeneralRKStep(ti,yi,A,gamma,beta1,beta2,h,f,fkt_calls)
    %matlabfunktion für einen einzelnen Schritt eines beliebigen Runge-Kutta
    %verfahren 
    %Input: Butchertableau, die Schrittweite h, die
    %rechten Seite der DGL sowie das aktuelle Wertepaar (ti,yi)
    
    %Rückgabe: y_(i+1) die neue Approximation bei ti+h

    %Konventionen für input:
    %f ist Spaltenvektor [ ; ; ...]
    %beta ist Spaltenvektor
    %gamma ist Spaltenvektor
    %y ist (wie f) Spaltenvektor

    beta2 = transpose(beta2);
    beta1 = transpose(beta1);
    %Intern ein mal transponieren weil ich Zeilenvektoren bevorzuge
    
   
    szRHS = size(yi,1); %Dimension der rechten Seite der DGL
    
    numStages = size(A,1); %Stufenzahl des Verfahrens
                           %Bemerkung: Hier wird nicht noch geprüft dass
                           %die eingaben des Nutzers "Sinnvoll" sind, also
                           %z.B. gamma und A kompatible Dimensionen haben.
                           %Das wäre in einer "richtigen" Implementation
                           %sicherlich hilfreich
    
    yi = yi';% Ich bevorzuge wieder Zeilenvektoren
    y1i= yi';
                     
    %Explizit lösen wir in g-form
     fbar = @(t,y) f(t',y')';%Ist nur ein kosmetischer Trick weil ich lieber
                             %Mit y, f als Zeilenvektoren
                             %arbeite
                             
    g = zeros(numStages,szRHS);%g's als Matrix der richtigen Dimension anlegen
        
                            %g nach Formel explizit berechnen
    for i = 1:numStages
        g(i,:) = yi;
        for j = 1:(i-1)
            fkt_calls=fkt_calls+1;
            g(i,:) = g(i,:) + h.*A(i,j).*fbar(ti + h*gamma(j),g(j,:));
        end
    end
    % zuerst ergebnis mit voll besetztem beta2 = Ordnung5
    y1i = yi;
    for i = 1:numStages
       fbar_val(i,:)=fbar(ti + h*gamma(i),g(i,:));
       fkt_calls=fkt_calls+1;
       yi = yi + h*beta2(i)*fbar_val(i,:); %y_(i+1) nach Formel
    end
    % ergbnis mit kürzerem beta1 berechnen = Ordnung4
    for i = 1:(numStages-1)
       y1i = y1i + h*beta1(i)*fbar_val(i,:); %y_(i+1) nach Formel
    end

    y1i= y1i';
    yi = yi'; %Zurücktransponieren der yi for Ende der Funktion damit das Ausgabe
              %Argument wieder Spaltenvektor genauso wie die Eingabe ist.

end

%--------------------------------------------------------------------------
%------------------ Differentialgleichungssystem  y' = y^2  ---------------

function [f, S] = create_DES()
    
    syms y(t)
    de = diff(y) == y^2;
    [V, S]=odeToVectorField(de);
    % Struktur von sym Y = [y; diff(y)]
    f = matlabFunction(V, 'vars', {'t','Y'});

end

