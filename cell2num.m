function mat=cell2num(input_cell) 
% The function converts an all numeric cell array to a double array. 
% Output matrix will have the same dimensions as the input cell array.

if ~iscell(input_cell)
    error('Error: input is not a cell array!'); 
end

mat=zeros(size(input_cell)); 
for n=1:size(input_cell,2) 
    for m=1:size(input_cell,1) 
        if isnumeric(input_cell{m,n}) 
            mat(m,n)=input_cell{m,n}; 
        else
            mat(m,n)=NaN; 
        end
    end
end

% reshape into 3x3 matrix
mat=reshape(mat,3,3);

end
