%% Aufgabe P6.1 - Gruppe 7 - Alexander Glock, Jannis Röder

clearvars

%f =@(x) cos(x) + exp(x) + 3*x.^2;
%a = 0;
%b = 5;

%[w, x] = trapezregel()
%[W, X] = transformation(w, x, a, 10)
%V = globaleQuadratur(f,w,x,0,5,3)

lokalerQuadraturfehler()

globalerQuadraturfehler()

%--------------------------------------------------------------------------
%--a) function [w,x] = trapezregel()  -------------------------------------

function [w,x] = trapezregel()
    
    w = [1/2, 1/2]';
    x = [0, 1]';

end

%--------------------------------------------------------------------------
%--b) function [w,x] = simpsonregel()  ------------------------------------

function [w,x] = simpsonregel()

    w = [1/6, 2/3, 1/6]';
    x = [0, 1/2, 1]';

end

%--------------------------------------------------------------------------
%--c) function [w,x] = transformation(w,x,a,b)  ---------------------------

function [W,X] = transformation(w,x,a,b)

    % n = length(w)-1;
    h = (b-a);
    
    W = w.*h;
    X = a + x.*h;

end    

%--------------------------------------------------------------------------
%--d) function v = lokaleQuadratur(f,w,x,a,b)  ----------------------------

function v = lokaleQuadratur(f,w,x,a,b)

    [W, X] = transformation(w, x, a, b);
    f_x = f(X(1:length(X)));
    v = dot(W, f_x);

end

%--------------------------------------------------------------------------
%--e) lokalerQuadraturfehler()  -------------------------------------------

function lokalerQuadraturfehler()

    a = 0;
    f =@(x) cos(x) + exp(x) + 3*x.^2;

    error_t = zeros(9, 1);
    error_s = error_t;
    error_od3 = error_t;
    error_od5 = error_t;
    bb = error_t;
    ll = (0:1:9);
    
    for l = ll
    
        b_l = 5/(2^l);
    
        % trapezregel ex=1
        [w, x] = trapezregel();
        v_t = lokaleQuadratur(f,w,x,a,b_l);
    
        % simpsonregel ex=3
        [w, x] = simpsonregel();
        v_s = lokaleQuadratur(f,w,x,a,b_l);
    
        % "exakte" LSg.
        I = integral(f, 0, b_l);
    
        % Fehler
        error_t(l+1) = abs(v_t-I);
        error_s(l+1) = abs(v_s-I);
        error_od3(l+1) = b_l^3;
        error_od5(l+1) = b_l^5;
    
        bb(l+1) = b_l;
    end
    
    figure
    loglog(bb, error_t, bb, error_s, bb, error_od3, bb, error_od5)
    title(" lokaler Quadraturfehler ")
    legend("trapez", "simpson", "b^3", "b^5")
    xlabel("b")
    ylabel("absoluter Fehler")

    % simpson konvergiert mit b^4,
    % trapez konvergiert mit b^3

end

%--------------------------------------------------------------------------
%--f) function V = globaleQuadratur(f,w,x,a,b,m)  -------------------------

function V = globaleQuadratur(f,w,x,a,b,m)
    
    Z_m = (a:(b-a)/m:b);
    kk = (1:1:m);
    V = 0;
    
    for k = kk
        % index shift wegen matlab, mathematisch ist hier k-1 korrekt ...
        a_m = Z_m(k);
        b_m = Z_m(k+1);
        V = V + lokaleQuadratur(f, w, x, a_m, b_m);
    end
end

%--------------------------------------------------------------------------
%--g) globalerQuadraturfehler()  ------------------------------------------

function globalerQuadraturfehler()

    f =@(x) cos(x) + exp(x) + 3*x.^2;
    a = 0;
    b = 5;
    
    mm = (1:1:100);
    error_t = zeros(100, 1);
    error_s = error_t;
    error_od4 = error_t;
    error_od2 = error_t;
    hh = error_t;
    
    % analytische Lsg.
    I = sin(5) + exp(5) + 124;
    
    % loop über WACHSENDES m = SINKENDES h
    for m = mm
    
        h_m = (b-a)/m;
    
        % trapez
        [w, x] = trapezregel();
        v_t = globaleQuadratur(f,w,x,a,b,m);
    
        % simpson
        [w, x] = simpsonregel();
        v_s = globaleQuadratur(f,w,x,a,b,m);
    
        % Fehler
        error_t(m) = abs(v_t-I);
        error_s(m) = abs(v_s-I);
        error_od4(m) = h_m^4;
        error_od2(m) = h_m^2;
    
        hh(m) = h_m;
    end
    
    figure
    loglog(hh, error_t, hh, error_s, hh, error_od2, hh, error_od4)
    title(" globaler Quadraturfehler ")
    legend("trapez", "simpson", "h^2", "h^4")
    xlabel("h")
    ylabel("absoluter Fehler")

    % simpson konv. mit ordnung h^3
    % trapez konv. mit ordnung h^2
end
