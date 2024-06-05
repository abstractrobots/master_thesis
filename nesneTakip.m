%Dosya okunur.
RGB = imread("sekiller.png");
%Siyah beyaz formata çevirilir.
I = im2gray(RGB);
%Siyah beyaz formattaki resim 1,0 cinsinden binarize edilir. 
%Elde edilen görüntü sadece siyah ve beyazdan oluşur.
bw = imbinarize(I,"adaptive","Sensitivity",0.4);
% figure(1)
imshowpair(RGB,bw,'montage')

%50 pixelden daha küçük objeler silinir.
minSize = 250;
bw1 = bwareaopen(bw,minSize);

%Resimdeki kenar boşlukları tespit edilip doldurulur.
% figure(2)
se = strel("disk",2);
bw2 = imclose(bw1,se);
imshowpair(bw1,bw2,'montage')

%Resimdeki tüm delikler doldurulur. Bu işlem sınırları elde etmek için
%kullanılan fonksiyona resmi hazırlamak içindir.
% figure(3)
bw3 = imfill(bw2,"holes");
imshowpair(bw3,bw2,'montage')

%Elde edilen şekillerin sınırları bwboundaries fonksiyonuyla çıkartılır.
% figure(4)
[B,L] = bwboundaries(bw3,"noholes");

%Elde edilen tüm sınırlar beyaz kenar çizgileriyle 
%renklendirilip resmin üzerinde çizdirilir.
imshow(label2rgb(L,@jet,[.5 .5 .5]))
hold on
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2),boundary(:,1),"w",LineWidth=2)
end
title("Objects with Boundaries in White")

%Elde edilen kenarların daireselliği kontrol edilir. 1'ise tam daire 0 ise
%daire değildir. 

stats = regionprops(L,"Circularity","Centroid");

%İstenilen sınır dairesellik sınırı belirlenir.

threshold = 0.5;

%Dairesellik sınırı geçen nesneler gösterilir. Sınırı geçen dairelerin
%merkezlerine dairesellik oranları yazılır.

for k = 1:length(B)

    % k'ıncı elemanın (X,Y) cinsinden sınırları
    boundary = B{k};

    % k'ıncı elemanın dairesellik değeri stringi oluşturulur.
    circ_value = stats(k).Circularity;
    circ_string = sprintf("%2.2f",circ_value);

    % Sınır değeri geçen nesneleri işaretlenir ve orta noktasına siyah nokta
    % koyulr
    if circ_value > threshold
        centroid = stats(k).Centroid;
        plot(centroid(1),centroid(2),"ko");
    end

    text(boundary(1,2)-35,boundary(1,1)+13,circ_string,Color="r",...
        FontSize=14,FontWeight="bold")

end

title("Dairesel Nesnelerin Sınırları ve Dairesellik Değerleri")

% Image origin coordinates
imageOrigin = [0.4,0.2,0.08];

% Scale factor to convert from pixels to physical distance
scale = 0.0005;

C = [];
for i=1:length(B)
C = [C;B{i}];
end

temp1 = [zeros(length(C),1),C];
temp1 = temp1*scale;
temp1(:,1) = objectPos;

waypoints = temp1';
offset_x = 0;
offset_y = -0.25;
offset_z = 0.15;
waypoints(1,:) = offset_x + waypoints(1,:);
waypoints(2,:) = offset_y + waypoints(2,:);
waypoints(3,:) = offset_z + waypoints(3,:);

orientations = pi/2*[ones(length(temp1),1) zeros(length(temp1),1) zeros(length(temp1),1)]';


scatter3(waypoints(1,:),waypoints(2,:),waypoints(3,:))
