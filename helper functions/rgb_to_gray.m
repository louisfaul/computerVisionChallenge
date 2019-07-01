function gray_image = rgb_to_gray(input_image)
% Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
% das Bild bereits in Graustufen vorliegt, soll es direkt zurueckgegeben werden.
[~,~,nChannels]=size(input_image);
if nChannels>1
    R=input_image(:,:,1);
    G=input_image(:,:,2);
    B=input_image(:,:,3);
    gray=0.299*double(R)+0.587*double(G)+0.114*double(B);
    gray_image=uint8(gray);
else
    gray_image=input_image;
end

end
