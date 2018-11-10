%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% En este script se seleccionara entre los 6 modos de trabajo que se desee
% para obtener el modelo del robot. En concreto se puede dar que:
% -> Robot ideal con Reductoras
% -> Robot ideal sin Reductoras
% -> Robot real solo encoder con Reductoras
% -> Robot real solo encoder sin Reductoras
% -> Robot real encoder y tacometro con Reductoras
% -> Robot real encoder y tacometro sin Reductoras
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

% Tiempo de muestreo
Tm=0.001;

selection='Seleccione el robot que busca modelar:\n 1.Robot ideal con reductoras.\n 2.Robot ideal sin reductoras.\n 3.Robot real solo encoder con Reductoras.\n 4.Robot real solo encoder sin Reductoras.\n 5.Robot real encoder y tacometro con Reductoras.\n 6.Robot real encoder y tacometro sin Reductoras.\n'; 
selec=input(selection);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% En el caso 1,2 -> se emplearan las medidas qi_D,qdi_D,qddi_D.
% En el caso 3,4 -> se emplearan las medidas qr_D,qd_fenco_D,qdd_fenco_D.
%                   (fenco = Filtrada del encoder)
% En el caso 5,6 -> se emplearan las medidas qr_D,qdr_D,qdd_ftaco_D.
%                   (ftaco = Filtrada del tacometro)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch selec
    
    % %%%%%%%% Robot ideal con reductoras %%%%%%%%%%%%%%%%%%
    case 1
        R1=50; R2=30; R3=15;    % Reductoras
        DatosSimSenoides;
        sim('sl_RobotReal_RRR');
        sl_RobotReal_RRR.slx = Simulink.exportToVersion(bdroot,'sl_RobotReal_RRR.slx','R2016b','BreakUserLinks',true);
        
        %graficas(t_D,Im_D,qi_D,qdi_D,qddi_D);
        ObtencionNumerica(t_D,Im_D,qi_D,qdi_D,qddi_D,R1,R2,R3);   % FALTA POR DEFINIR QUE LE PASAMOS EN CADA CASO    
        % Si las cosas han ido bien, apareceran por terminal las variables
        % Ma,Va y Ga. Si es asi, ahora se deberan modificar las matrices
        % del script "ModeloDinamico_RRR_sl.m". Tras ello, se debera hacer
        % lo siguiente:
         sim('sl_RobotModelo_RRR');
        % graficas(t_D,Im_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
         graf_error(t_D,Im_D,qi_D,qdi_D,qddi_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
         graf_sismod(t_D,qi_D,qdi_D,qddi_D,qi_D_mod,qdi_D_mod,qddi_D_mod,1);
        % Y ANALIZAR LOS RESULTADOS.
        
    % %%%%%%%% Robot ideal sin reductoras %%%%%%%%%%%%%%%%%%
    % (RECORDAR ACTIVAR EL ACCIONAMIENTO DIRECTO)
    case 2
        R1=1; R2=1; R3=1;    % Reductoras
        DatosSimSenoides;
        sim('sl_RobotReal_RRR');
        % graficas(t_D,Im_D,qi_D,qdi_D,qddi_D);
        ObtencionNumerica(t_D,Im_D,qi_D,qdi_D,qddi_D,R1,R2,R3);
        % Si las cosas han ido bien, apareceran por terminal las variables
        % Ma,Va y Ga. Si es asi, ahora se deberan modificar las matrices
        % del script "ModeloDinamico_RRR_sl.m". Tras ello, se debera hacer
        % lo siguiente:
        % sim('sl_RobotModelo_RRR');
        % graficas(t_D,Im_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % graf_error(t_D,Im_D,qi_D,qdi_D,qddi_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % Y ANALIZAR LOS RESULTADOS.
    
    %  %%%%%%%% Robot real solo encoder con Reductoras %%%%%%%%
    case 3
        R1=50; R2=30; R3=15;    % Reductoras
        
        ord_fil1=2;          % Orden del filtro Butterworth
        wc1=5/(1/Tm)+0.1;    % Frecuencia de corte del Butterworth. Se haya 
                            % como la frecuencia de corte deseada, 5Hz,
                            % entre la frecuencia de muestreo
        DatosSimSenoides;
        sim('sl_RobotReal_RRR');
        % Aplicacion del filtro de Butterworth a las medidas reales
        [b1,a1]=butter(ord_fil1,wc1);
        qr_filt=filter(b1,a1,qr_D);
        
        % Aplicacion del filtro no causal para obtener la velocidad
        % estimada
        qd_est=filtroNoCausal_derivada(t_D,qr_filt,Tm);   % Obtencion de la derivada
        
         figure();subplot(311);plot(t_D,qdi_D(:,1));title('Velocidad ideal'); grid; subplot(312);plot(t_D,qdi_D(:,2));grid;subplot(313);plot(t_D,qdi_D(:,3));grid;
         figure();subplot(311);plot(t_D,qd_est(:,1));title('Velocidad estimada'); grid; subplot(312);plot(t_D,qd_est(:,2));grid;subplot(313);plot(t_D,qd_est(:,3));grid;
         figure();subplot(311);plot(t_D,qdi_D(:,1)-qd_est(:,1)); title('Error Velocidad');grid; subplot(312);plot(t_D,qdi_D(:,2)-qd_est(:,2));grid;subplot(313);plot(t_D,qdi_D(:,3)-qd_est(:,3));grid;
       
        ord_fil2=4;          % Orden del filtro Butterworth
        wc2=5/(1/Tm)+0.1;    % Frecuencia de corte del Butterworth. 
        % Aplicacion del filtro de Butterworth a la medida estimada de
        % velocidad para estimar la aceleracion
        [b2,a2]=butter(ord_fil2,wc2);
        qd_est_filt=filter(b2,a2,qd_est);
        
        % Aplicacion del filtro no causal para obtener la velocidad
        % estimada
        qdd_est=filtroNoCausal_derivada(t_D,qd_est_filt,Tm);   % Obtencion de la derivada

         figure();subplot(311);plot(t_D,qddi_D(:,1));title('Aceleracion ideal'); grid; subplot(312);plot(t_D,qddi_D(:,2));grid;subplot(313);plot(t_D,qddi_D(:,3));grid;
         figure();subplot(311);plot(t_D,qdd_est(:,1));title('Aceleracion estimada'); grid; subplot(312);plot(t_D,qdd_est(:,2));grid;subplot(313);plot(t_D,qdd_est(:,3));grid;
         figure();subplot(311);plot(t_D,qddi_D(:,1)-qdd_est(:,1)); title('Error Aceleracion');grid; subplot(312);plot(t_D,qddi_D(:,2)-qdd_est(:,2));grid;subplot(313);plot(t_D,qddi_D(:,3)-qdd_est(:,3));grid;

               
    %     ObtencionNumerica(t_D,Im_D,qr_D,qd_est,qdd_est,R1,R2,R3);
        % Si las cosas han ido bien, apareceran por terminal las variables
        % Ma,Va y Ga. Si es asi, ahora se deberan modificar las matrices
        % del script "ModeloDinamico_RRR_sl.m". Tras ello, se debera hacer
        % lo siguiente:
        % sim('sl_RobotReal_RRR');
        % graficas(t_D,Im_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % graf_error(t_D,Im_D,qi_D,qdi_D,qddi_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % Y ANALIZAR LOS RESULTADOS.
        
        
    % %%%%%%%% Robot real solo encoder sin Reductoras %%%%%%%% 
    % (RECORDAR ACTIVAR EL ACCIONAMIENTO DIRECTO)
    case 4
        R1=1; R2=1; R3=1;    % Reductoras
        DatosSimSenoides;
        sim('sl_RobotReal_RRR');
        graficas(t_D,Im_D,qr_D,qd_fenco_D,qdd_fenco_D);
        ObtencionNumerica(t_D,Im_D,qr_D,qd_fenco_D,qdd_fenco_D,R1,R2,R3);
        % Si las cosas han ido bien, apareceran por terminal las variables
        % Ma,Va y Ga. Si es asi, ahora se deberan modificar las matrices
        % del script "ModeloDinamico_RRR_sl.m". Tras ello, se debera hacer
        % lo siguiente:
        % sim('sl_RobotReal_RRR');
        % graficas(t_D,Im_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % graf_error(t_D,Im_D,qi_D,qdi_D,qddi_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % Y ANALIZAR LOS RESULTADOS.
        
    %  %%%%%%%% Robot real encoder y tacometro con Reductoras %%%%%%%%   
    case 5
        R1=50   ; R2=30; R3=15;    % Reductoras
        DatosSimSenoides;
        sim('sl_RobotReal_RRR');
        
        ord_fil=4;          % Orden del filtro Butterworth
        wc=5/(1/Tm);    % Frecuencia de corte del Butterworth. 
        % Aplicacion del filtro de Butterworth a la medida estimada de
        % velocidad para estimar la aceleracion
        [b,a]=butter(ord_fil,wc);
        qdr_filt=filter(b,a,qdr_D);
        
        % Aplicacion del filtro no causal para obtener la velocidad
        % estimada
        qdd_est=filtroNoCausal_derivada(t_D,qdr_filt,Tm);   % Obtencion de la derivada
        
         figure();subplot(311);plot(t_D,qddi_D(:,1));title('Aceleracion ideal'); grid; subplot(312);plot(t_D,qddi_D(:,2));grid;subplot(313);plot(t_D,qddi_D(:,3));grid;
         figure();subplot(311);plot(t_D,qdd_est(:,1));title('Aceleracion estimada'); grid; subplot(312);plot(t_D,qdd_est(:,2));grid;subplot(313);plot(t_D,qdd_est(:,3));grid;
         figure();subplot(311);plot(t_D,qddi_D(:,1)-qdd_est(:,1)); title('Error Aceleracion');grid; subplot(312);plot(t_D,qddi_D(:,2)-qdd_est(:,2));grid;subplot(313);plot(t_D,qddi_D(:,3)-qdd_est(:,3));grid;

        
        % graficas(t_D,Im_D,qr_D,qdr_D,qdd_ftaco_D);
        % ObtencionNumerica(t_D,Im_D,qr_D,qdr_D,qdd_ftaco_D,R1,R2,R3);
        % Si las cosas han ido bien, apareceran por terminal las variables
        % Ma,Va y Ga. Si es asi, ahora se deberan modificar las matrices
        % del script "ModeloDinamico_RRR_sl.m". Tras ello, se debera hacer
        % lo siguiente:
        % sim('sl_RobotReal_RRR');
        % graficas(t_D,Im_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % graf_error(t_D,Im_D,qi_D,qdi_D,qddi_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % Y ANALIZAR LOS RESULTADOS.
    
    % %%%%%%%% Robot real encoder y tacometro sin Reductoras %%%%%%%%
    % (RECORDAR ACTIVAR EL ACCIONAMIENTO DIRECTO)
    case 6
        R1=1; R2=1; R3=1;    % Reductoras
        DatosSimSenoides;
        sim('sl_RobotReal_RRR');
        graficas(t_D,Im_D,qr_D,qdr_D,qdd_ftaco_D);
        ObtencionNumerica(t_D,Im_D,qr_D,qdr_D,qdd_ftaco_D,R1,R2,R3);
        % Si las cosas han ido bien, apareceran por terminal las variables
        % Ma,Va y Ga. Si es asi, ahora se deberan modificar las matrices
        % del script "ModeloDinamico_RRR_sl.m". Tras ello, se debera hacer
        % lo siguiente:
        % sim('sl_RobotReal_RRR');
        % graficas(t_D,Im_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % graf_error(t_D,Im_D,qi_D,qdi_D,qddi_D,qi_D_mod,qdi_D_mod,qddi_D_mod);
        % Y ANALIZAR LOS RESULTADOS.
        
end