function [ sal ] = randomGen_Exponencial( media, n, m )
% function [ sal ] = randomGen_Exponencial( media, n, m )
% Funcion que genera numeros aleatorios segun una funcion exponencial
% n = numero de filas de numeros aleatorios a generar
% m = numero de columnas de numeros aleatorios a generar
% media = media de los valores aleatorios generados
% Normalmente se habla del parametro lambda de la exponencial que es la
% inversa de la media (lambda=1/media)
% En una funcion exponencial, F(x)=1-exp(-lambda*x), F(x) es la CDF de la
% funcion:
% x=(-1/lambda)*ln(1-r)=-media**ln(1-r)

    sal=(-media)*log(1-rand(n,m));
end

