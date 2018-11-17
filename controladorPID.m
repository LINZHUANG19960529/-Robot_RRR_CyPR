%% CONTROLADOR IMPLEMENTADO EN DISCRETO
% IMPLEMENTACION DE UN CONTROLADOR PD EN DISCRETO

function [I_control]=controlador(in)
  % Definicion de entradas del controlador
  q1ref_k = in(1);   % Posiciones de referencia
  q2ref_k = in(2);
  q3ref_k = in(3);
    
  q1_k = in(4);   % Posiciones articulares del robot
  q2_k = in(5);
  q3_k = in(6);

  qd1ref_k = in(7);   % Velocidades de referencia
  qd2ref_k = in(8);
  qd3ref_k = in(9);
    
  qd1_k = in(10);   % Velocidades articulares del robot
  qd2_k = in(11);
  qd3_k = in(12);
%   
%   qdd1ref_k = in(13);   % Aceleraciones de referencia
%   qdd2ref_k = in(14);
%   qdd3ref_k = in(15);
%     
%   qdd1_k = in(16);   % Aceleraciones articulares del robot
%   qdd2_k = in(17);
%   qdd3_k = in(18);
  
  
    t = in(13);       % Tiempo de simulacion
  
  % Se emplean variables persistentes para que mantengan su valor cada vez
  % que se entre en la funcion.
  persistent Int_e1 Int_e2 Int_e3;
    persistent e1_k1 e2_k1 e3_k1;
  % Definicion del tiempo de subida en bucle cerrado
  ts_bc=50e-3;

  % Definicion de las intensidades de equilibrio
  Im1_eq=0;
  Im2_eq=0;
  Im3_eq=0;
  
  % Tiempo de muestro
  Tm=0.001;
  
  % Inicializacion de variables
 if (t<1e-8) Int_e1=0; Int_e2=0; Int_e3=0; e1_k1=0; e2_k1=0; e3_k1=0; end

  % Calculo de los errores -> No se hasta que punto es mejor hayarlo aqui o
  % que sea la entrada del controlador
  e1_k= q1ref_k - q1_k;
  e2_k= q2ref_k - q2_k;
  e3_k= q3ref_k - q3_k;
  
  ed1_k= qd1ref_k - qd1_k;
  ed2_k= qd2ref_k - qd2_k;
  ed3_k= qd3ref_k - qd3_k;
  
  % Definicion de parametros del controlador PID sin cancelacion
  % Ts_bc=50ms
  Ti1=2*0.18; Td1=(2*(0.18^2))/Ti1;   Kp1=68.115*Ti1;
  Ti2=2*0.19; Td2=(2*(0.19^2))/Ti2;   Kp2=513.04*Ti2; 
  Ti3=2*0.18; Td3=(2*(0.18^2))/Ti3;   Kp3=542.09*Ti3; 
  % Componentes del controlador discreto empleando la aproximacion de 
  % Euler II
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  %        q0+q1*z+q2*z^2
  %  C(z)= ---------------
  %            (z-1)z
  %%%%%%%%%%%%%%%%%%%%%%%%%%
%   for i=1:3
%     q0(i)=Kp(i)*(1+(Tm/Ti(i))+(Td(i)/Tm));
%     q1(i)=Kp(i)*(-1-2*(Td(i)/Tm));
%     q2(i)=Kp(i)*(Td(i)/Tm);
%   end



I1_k=Kp1*(e1_k + (Td1/Tm)*(e1_k-e1_k1) + (1/Ti1)*Int_e1);
I2_k=Kp2*(e2_k + (Td2/Tm)*(e2_k-e2_k1) + (1/Ti2)*Int_e2);
I3_k=Kp3*(e3_k + (Td3/Tm)*(e3_k-e3_k1) + (1/Ti3)*Int_e3);

 Int_e1 = e1_k*Tm + Int_e1;
 Int_e2 = e2_k*Tm + Int_e2;
 Int_e3 = e3_k*Tm + Int_e3;

% actualizacion
e1_k1=e1_k; e2_k1=e2_k; e3_k1=e3_k;


  % Calculo de la se�al de control abosluta (incremento+Valor de equilibrio)
  Im1_k=I1_k+Im1_eq; 
  Im2_k=I2_k+Im2_eq;
  Im3_k=I3_k+Im3_eq;
    
  % AQUI SE A�ADIRIA LA SATURACION DEL SISTEMA SI FUERA NECESARIO
  
  % Devolvemos como parametro la se�al de control absoluta
  I_control=[Im1_k Im2_k Im3_k];
end