function Cake = cake(min_dist)
% Die Funktion cake erstellt eine "Kuchenmatrix", die eine kreisfoermige
% Anordnung von Nullen beinhaltet und den Rest der Matrix mit Einsen
% auffuellt. Damit koennen, ausgehend vom staerksten Merkmal, andere Punkte
% unterdrueckt werden, die den Mindestabstand hierzu nicht einhalten.

% create zeros matrix
dist_mat=zeros(min_dist*2+1);
% fill it with distances to the center of the matrix i.e. number with coordinates (min_dist+1,min_dist+1)
% To verify if point belongs to a circle its coordinates must satisfy the following equation: (x-a)^2+(y-b)^2<=R^2
% In our case (a,b)= (min_dist+1,min_dist+1): center of the circle and R= min_dist
for i=1:size(dist_mat,1) %rows
    for j=1:size(dist_mat,2) %columns
        dist_mat(i,j)=sqrt((i-min_dist-1)^2+(j-min_dist-1)^2);
    end
end

% go througth distance matrix and fill it with zero if distance is less or equal to min_dist, otherwise with 1
for i=1:size(dist_mat,1) %rows
    for j=1:size(dist_mat,2) %columns
        if dist_mat(i,j)<=min_dist
            dist_mat(i,j)=0;
        else
            dist_mat(i,j)=1;
        end
    end
end

% create the cake matrix
Cake=logical(dist_mat==1);

end