clc, clear, close all;

imagen= imread("Im046_ACRIMA.jpg");


%CONTRIBUCION DE CADA COLOR

% Escalar los canales a valores entre 0 y 1
canal_rojo = double(imagen(:,:,1)) / 255.0;
canal_verde = double(imagen(:,:,2)) / 255.0;
canal_azul = double(imagen(:,:,3)) / 255.0;

% Crear imágenes para cada canal
imagen_roja = zeros(size(imagen));
imagen_roja(:,:,1) = canal_rojo;

imagen_verde = zeros(size(imagen));
imagen_verde(:,:,2) = canal_verde;

imagen_azul = zeros(size(imagen));
imagen_azul(:,:,3) = canal_azul;

% Combinaciones de canales
imagen_azul_roja = cat(3,canal_rojo , zeros(size(imagen(:,:,1))), canal_azul);
imagen_azul_verde = cat(3, zeros(size(imagen(:,:,1))), canal_verde , canal_azul );
imagen_roja_verde = cat(3, canal_rojo, canal_verde, zeros(size(imagen(:,:,1))));


% Mostrar las imágenes
figure;

subplot(2,4,1);
imshow(imagen);
title('Imagen Original');

subplot(2,4,2);
imshow(canal_rojo);
title('Canal Rojo');

subplot(2,4,3);
imshow(canal_verde);
title('Canal Verde');

subplot(2,4,4);
imshow(canal_azul);
title('Canal Azul');

subplot(2,4,8);
imshow(imagen_roja_verde);
title('Combinación Rojo-Verde');

subplot(2,4,6);
imshow(imagen_azul_roja);
title('Combinación Azul-Roja');

subplot(2,4,7);
imshow(imagen_azul_verde);
title('Combinación Azul-Verde');



%KMEANS
imagen_azul_roja = rgb2gray(imagen_azul_roja);
imagen_azul_verde = rgb2gray(imagen_azul_verde);
imagen_roja_verde = rgb2gray(imagen_roja_verde);

% Número de clases (en este caso, 2)
num_clusters = 2;

% Segmentar cada canal con k-means
[idx_rojo, centroids_rojo] = kmeans(canal_rojo(:), num_clusters);
[idx_verde, centroids_verde] = kmeans(canal_verde(:), num_clusters);
[idx_azul, centroids_azul] = kmeans(canal_azul(:), num_clusters);
[idx_azul_roja, centroids_azul_roja] = kmeans(imagen_azul_roja(:), num_clusters);
[idx_azul_verde, centroids_azul_verde] = kmeans(imagen_azul_verde(:), num_clusters);
[idx_roja_verde, centroids_roja_verde] = kmeans(imagen_roja_verde(:), num_clusters);

% Reconstruir las imágenes segmentadas
imagen_segmentada_rojo = reshape(centroids_rojo(idx_rojo), size(imagen(:,:,1)));
imagen_segmentada_verde = reshape(centroids_verde(idx_verde), size(imagen(:,:,2)));
imagen_segmentada_azul = reshape(centroids_azul(idx_azul), size(imagen(:,:,3)));
imagen_segmentada_azul_roja = reshape(centroids_azul_roja(idx_azul_roja), size(imagen_azul_roja));
imagen_segmentada_azul_verde = reshape(centroids_azul_verde(idx_azul_verde), size(imagen_azul_verde));
imagen_segmentada_roja_verde = reshape(centroids_roja_verde(idx_roja_verde), size(imagen_roja_verde));

% Combinar los canales segmentados en una imagen RGB
imagen_segmentada_rgb = cat(3, imagen_segmentada_rojo, imagen_segmentada_verde, imagen_segmentada_azul);

% Mostrar las imágenes
figure;

subplot(2,3,1);
imshow(imagen_segmentada_azul);
title('Segmentación Canal Azul');
subplot(2,3,2);
imshow(imagen_segmentada_rojo);
title('Segmentación Canal Rojo');
subplot(2,3,3);
imshow(imagen_segmentada_verde);
title('Segmentación Canal Verde');
subplot(2,3,4);
imshow(imagen_segmentada_roja_verde);
title('Segmentación Roja-Verde');
subplot(2,3,5);
imshow(imagen_segmentada_azul_roja);
title('Segmentación Azul-Rojo');
subplot(2,3,6);
imshow(imagen_segmentada_azul_verde);
title('Segmentación Azul-Verde');
% Mostrar la imagen RGB segmentada
figure;
imshow(imagen_segmentada_rgb);
title('Imagen Segmentada (RGB)');


% HALLAR CIRCULO

% Coordenadas del centro y radio del círculo

imagen_circulo_COPA=imagen_segmentada_azul_verde;
imagen_circulo_DISCO=imagen_segmentada_rojo;


% Convertir a escala de grises y suavizar
imagen_suavizada_COPA = imgaussfilt(imagen_circulo_COPA, 2); 
imagen_suavizada_DISCO = imgaussfilt(imagen_circulo_DISCO, 2); 

% OTSU-COPA
umbral_otsu = graythresh(imagen_suavizada_COPA);
imagen_binarizada_COPA = imbinarize(imagen_suavizada_COPA, umbral_otsu);
% OTSU-DISCO
umbral_otsu = graythresh(imagen_suavizada_DISCO);
imagen_binarizada_DISCO = imbinarize(imagen_suavizada_DISCO, umbral_otsu);

% Aplicar un detector de bordes (puedes probar diferentes métodos)
imagen_bordes_COPA = edge(imagen_suavizada_COPA, 'Sobel');
imagen_bordes_DISCO = edge(imagen_suavizada_DISCO, 'Sobel');


area_circulo_COPA=sum(imagen_binarizada_COPA(:));
radio_circulo_COPA = sqrt(area_circulo_COPA / pi);

area_circulo_DISCO=sum(imagen_binarizada_DISCO(:));
radio_circulo_DISCO = sqrt(area_circulo_DISCO / pi);


% Calculate centroid -COPA
    [m, n] = size(imagen_circulo_COPA);
    sumx_COPA = 0;
    sumy_COPA = 0;
    mu00_COPA = sum(imagen_circulo_COPA(:)); % µ00

    for x = 1:m
        for y = 1:n
            sumx_COPA = sumx_COPA + x * imagen_circulo_COPA(x, y);
            sumy_COPA = sumy_COPA + y * imagen_circulo_COPA(x, y);
        end
    end
    % Calculate centroid coordinates
    Cx_COPA = sumx_COPA / mu00_COPA;
    Cy_COPA = sumy_COPA / mu00_COPA;

  % Calculate centroid -DISCO
    [m, n] = size(imagen_circulo_DISCO);
    sumx_DISCO = 0;
    sumy_DISCO = 0;
    mu00_DISCO = sum(imagen_circulo_DISCO(:)); % µ00

    for x = 1:m
        for y = 1:n
            sumx_DISCO = sumx_DISCO + x * imagen_circulo_DISCO(x, y);
            sumy_DISCO = sumy_DISCO + y * imagen_circulo_DISCO(x, y);
        end
    end
    % Calculate centroid coordinates
    Cx_DISCO = sumx_DISCO / mu00_DISCO;
    Cy_DISCO = sumy_DISCO / mu00_DISCO;


% Mostrar la imagen original y los círculos detectados en el canal rojo
figure;

subplot(2,3,1);
imshow(imagen_circulo_COPA);
title('Imagen Segmentada Original');

subplot(2,3,2);
imshow(imagen_bordes_COPA);
title('Bordes detectados Copa');

subplot(2,3,3);
imshow(imagen_circulo_COPA);
title('Círculos detectados- COPA');
hold on;
viscircles([Cx_COPA Cy_COPA], radio_circulo_COPA, 'EdgeColor', 'b'); % Dibujar círculos detectados en la imagen
hold off;

subplot(2,3,4);
imshow(imagen_circulo_DISCO);
title('Imagen Segmentada Original');

subplot(2,3,5);
imshow(imagen_bordes_DISCO);
title('Bordes detectados Disco');

subplot(2,3,6);
imshow(imagen_circulo_DISCO);
title('Círculos detectados- DISCO');
hold on;
viscircles([Cx_DISCO Cy_DISCO], radio_circulo_DISCO, 'EdgeColor', 'r'); % Dibujar círculos detectados en la imagen
hold off;