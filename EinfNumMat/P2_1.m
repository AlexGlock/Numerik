%% Aufgabe P2.1 - Gruppe 7 - Alexander Glock, Jannis Röder
clearvars

%A=[4 12 -16; 12 37 -43; -16 -43 98]        % Cholesky Test
%C = cholesky_zerlegung(A);
%C*C'

%A=[1 2 3; 1 1 1; 3 3 1]                    % LR Test
%[L,R,P]=lr_zerlegung(A);
%L*R
%P*A

%Laplace_Mat(6)                             % Laplace Test  

stabilitaet(30)                             % Stabilitätsanalyse

%--------------------------------------------------------------------------
%---------------------  Ergebnisse    -------------------------------------
%
% Der Verfahrensfehler der LR-Zerlegung ( P_m A_m - L_m R_m ) verhält
% sich wie erwartet und wächst kontinuierlich mit der Matrixdimension. Der
% Fehler der cholesky-Zerlegung fällt für kleine Matrix Dimensionen sogar
% etwas ab und wächst insgesamt weniger stark als der erste Fehler. Das
% cholesky-Verfahren scheint bei der Berechnung der Zerlegung weniger
% sensititv auf die Matrixdimension zu sein als die LR-Zerlegung, was an
% der Anzahl der Punktoperationen und den damit verbundenen Rundungsfehlern
% zu erklären ist, die bei der LR-zerlegung mittels Gauss mit höherer
% Ordnung ansteigen als bei cholesky.

% Die Entwicklung der Berechnungsdauer lässt sich auf ähnliche Weise
% erklären. Hierbei wird jedoch nicht zwischen den Verfahren unterschieden
% sondern es findet ein gewisser Mittelungseffekt statt, da immer nur die
% summierte Dauer für alle Zerlegungen gemessen wird. Natürlich steigt der
% Rechenaufwand für alle Verfahren mit der Matrisdimension, was im Graphen
% anhand des Wachstums zu sehen ist. 

% Die Algorithmen scheinen allerdings besonders genau bei einer Dimension
% von m=2 und besonders schnell bei einer Dimension von m = 3 zu sein, denn
% dort haben die Graphen jeweils ihr Minimum bevor sie in ein nahezu
% kontinuierliches wachstum übergehen.

%--------------------------------------------------------------------------
%--------------------- c) Laplace-Matrix  ---------------------------------

function A = Laplace_Mat(m)
    B = zeros(m)+diag(4*ones(1,m))+diag((-1)*ones(1,m-1),-1)+diag((-1)*ones(1,m-1),1);
    Id = eye(m);
    Z = zeros(m,m);
    
    % Null Matrix + Hauptdiagonale
    A = zeros(m^2,m^2)+diag(4*ones(1,m^2));
    % Nebendiagonalen mit Unterbrechungen bauen und addieren:
    n_diag=[0,ones(1,m-1)];
    dg=n_diag;
    for ind = 2:1:m
        dg=[dg,n_diag];
    end 
    %n_diag%diag(n_diag(2:end),-1)
    A=A+diag(dg(2:end),-1)+diag(dg(2:end),1);
    % Diagonalen der Einheitsmatrizen addieren:
    A=A+diag(ones(1,m^2-m),m)+diag(ones(1,m^2-m),-m);
end

%--------------------------------------------------------------------------
%--------------------- a)  LR-Zerlegung    --------------------------------

function [L,R,P] = lr_zerlegung(A)
    % Thomas Algorithmus
    n = size(A,1);

    L=eye(n);
    P=eye(n);
    
    for j=1:n % über jede Spalte
        %Pivotisierung
        [~,i]=max(abs(A(j:n,j)));
        i=i+(j-1);

        %Tauschen der Elemente
        for k=j:n
            tmp=A(i,k);
            A(i,k)=A(j,k);
            A(j,k)=tmp;
        end
        % Perm Matrix Zeilentausch wie A
        tmp2=P(i,:);
        P(i,:)=P(j,:);
        P(j,:)=tmp2;

        %Nullen in j-ten Spalten erzeugen
        for i=(j+1):n
            q=A(i,j)/A(j,j);
            L(i,j)=q;
            for k=j:n
                A(i,k)=A(i,k)-q*A(j,k);
            end

        end
    end

    R=A;
end

%--------------------------------------------------------------------------
%--------------------- b) cholesky-Zerlegung    ---------------------------

function C = cholesky_zerlegung(A)
    n = size(A,1);
    L = zeros(n);
    for j=1:n % Laufe uber Spalten von A ¨
    % Berechne Diagonalelemente
        sum=0;
        for k=1:(j-1)
            sum = sum + L( j , k )^2;
        end
        L(j,j) = sqrt(A(j,j)-sum);
        % Berechne Rest der j-ten Spalte
        for i=(j+1):n
            sum=0;
            for k=1:(j-1)
                sum=sum+L(i,k)*L(j,k);
            end
            L(i,j)=(A(i,j)-sum)/L(j,j);
        end
    end
    C=L;
end

%--------------------------------------------------------------------------
%--------------------- i) ii) stabilitaet  --------------------------------

function stabilitaet(M)

    % fehlervektoren initialisieren:
    E1=zeros(1,M);
    E2=zeros(1,M);
    mm=(1:1:M);

    % Aufgabe (ii) - Zeitmessung
    tt=zeros(1,M);
    
    % loop über größer werdende Dimension m
    for m=mm(1:end)
        tic;
        % Laplace Matrix dim m
        A=Laplace_Mat(m);
        % LR mit Pivotisierung für jede A
        [L,R,P]=lr_zerlegung(A);
        % Cholesky für jede A
        C = cholesky_zerlegung(A);
        % Dauer der Zerlegungen
        tt(m)=toc;
    
        %Fehler für jeweilige Iteration
        E1(m)=norm((P*A-L*R),'inf');
        E2(m)=norm((A-C*C'),'inf');
    end
    
    % plot der Fehler gegen m
    figure
    loglog(mm,E1(1:end),mm,E2(1:end))
    title('Fehler der Algorithmen bei zunehmendem m')
    legend('| P_m A_m - L_m R_m |_\infty','| A_m - C_m (C_m)^T|_\infty')
    xlabel('Matrixgröße m')
    ylabel('Fehler in der Unendlichnorm')
    grid on

    % plot der ben. Zeit gegen m
    figure
    loglog(mm,tt)
    title('Dauer der Zerlegungen bei zunehmendem m')
    xlabel('Matrixgröße m')
    ylabel('Dauer in Sekunden')
    grid on
end

