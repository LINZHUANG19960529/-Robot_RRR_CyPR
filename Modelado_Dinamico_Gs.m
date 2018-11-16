%% MODELADO CINEMATICO DEL ROBOT
% Obtenci�n del modelo a partir de las ecuaciones dinamicas para cada
% articulacion.

% %%%%%%% MODELO CON REDUCTORAS DEL ROBOT IDEAL %%%%%%%%%%%%%%%
% Ma11=0.088863*cos(2.0*q2 + q3) + 0.1189*cos(2.0*q2) + 0.088863*cos(q3) + 0.029404*cos(2.0*q2 + 2.0*q3) + 1.1525
% Ma22=0.37026*cos(q3) + 5.8299
% Ma33=2.4628
% Para linealizar se tomaran todas las q como cero (Otro modo seria
% despreciar todo lo que no sea termino independiente).

% Va1=-8.6736e-21*qd1*(2.049e19*qd2*sin(2.0*q2 + q3) + 1.0245e19*qd3*sin(2.0*q2 + q3) + 2.7416e19*qd2*sin(2.0*q2) + 1.0245e19*qd3*sin(q3) + 6.7799e18*qd2*sin(2.0*q2 + 2.0*q3) + 6.7799e18*qd3*sin(2.0*q2 + 2.0*q3) - 1.3834e19)
% Va2=0.063796*qd2 - 0.18513*qd3^2*sin(q3) + 0.061258*qd1^2*sin(2.0*q2 + 2.0*q3) + 0.18513*qd1^2*sin(2.0*q2 + q3) + 0.2477*qd1^2*sin(2.0*q2) - 0.37026*qd2*qd3*sin(q3)
% Va3=0.064287*qd3 + 0.21158*qd1^2*sin(q3) + 0.42316*qd2^2*sin(q3) + 0.14003*qd1^2*sin(2.0*q2 + 2.0*q3) + 0.21158*qd1^2*sin(2.0*q2 + q3)
% Para linealizar la matriz V, se tomar�n �nicamente los terminos que
% acompa�en la derivada de la componente que se est� hayando, por ejemplo,
% en este caso ser�a
% Va1=0.1200*qd1
% Va2=0.063796*qd2 
% Va3=0.064287*qd3

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g=9.8;L0=0.6;L1=0.6;L2=1;L3=0.8;
Kt1=0.5; Kt2=0.4; Kt3 =0.35;

% Se decide entre usar reductoras o no
if (flag==1)
    R1=50; R2=30; R3=15;   
elseif (flag==0)
    R1=1; R2=1; R3=1;   
end

% %%%% ROBOT IDEAL CON REDUCTORAS %%%%
% Obtencion del termino de la matriz de inercias simplificado
Ma1=1.4785; %Ma1=eval( subs(subs(subs(Ma11,q1,0),q2,0),q3,0)); 
Ma2=6.2002; %Ma2=eval( subs(subs(subs(Ma22,q1,0),q2,0),q3,0)); 
Ma3=2.4628; %Ma3=eval( subs(subs(subs(Ma33,q1,0),q2,0),q3,0)); 

% Se ha extraido los valores de las Bm_i de los parametros tetha_li
Va1=0.1200;     % Bm*(R^2)
Va2=0.063796;
Va3=0.064287;

% Obtencion de las funciones de transferencia
numG1=Kt1*R1;
denG1=conv([1 0],[Ma1 Va1]);
G1=tf(numG1,denG1);

numG2=Kt2*R2;
denG2=conv([1 0],[Ma2 Va2]);
G2=tf(numG2,denG2);

numG3=Kt3*R3;
denG3=conv([1 0],[Ma3 Va3]);
G3=tf(numG3,denG3);