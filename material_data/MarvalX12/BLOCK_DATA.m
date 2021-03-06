function [ VariantenSort, strainSort  ] = BLOCK_DATA( )  %[ blockpairs, n1, n2]
%all Angels in Radians!!! Matlab Standard

clc
format short

% Der mittlere Eigenwert ist hier also n1. Dieser soll auf 1.0 getuned
% werden. Die differenz ist also (n1-1).
% B3 = [eta1 0    0   
%        0  eta1  0
%        0  0  eta3];
%    
% det(B3)

% Khachaturyan Paper...
% Viel zu hohe Volums�nderung von 6% aus�erdem �nderung gegen�ber
% Bainstrain, was nicht erkl�rbar ist (ws grosse Rundungsfehler) 
A1 = [1.0928   0.1034  0.1022;   
      0.0928   1.1034  0.1022;  
     -0.1369  -0.1581  0.8464];
 
block = [1.0981   0.0981  0.1022;   
         0.0981   1.0981  0.1022;  
        -0.1475  -0.1475  0.8464];
    
    [E,V] = eigs(block)
    
    [~,R] = polardecomposition( block );
    vec4 = vrrotmat2vec( R );
    vec4(4) = rad2deg( vec4(4) )
 
det(A1)
det(block)
 
%A2 = (block - eye(3) )*0.5;
%A1 = A2 +eye(3);
%det(A1)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% assemble all rotations that map the cubic lattice back to itself
Rot_Matrizen = cubic_pointgroup_rotations();

for i=1:size(Rot_Matrizen,3)
    block_variants(:,:,i) = (Rot_Matrizen(:,:,i)) * block * Rot_Matrizen(:,:,i)';
end

VariantenSort = matrixArray_reduzieren(block_variants, 1e-4);

% it turned out that i get all 24 Block variants, and I found that 
% I started with shape deformation A_1^1 Eq. 38 as in Paper and my 12 is his second block variant
% J.W. Morris Paper, dislocated microstructure...
operator = VariantenSort(:,:,12)*inv(VariantenSort(:,:,1));
for i=1:size(Rot_Matrizen,3)
    all_operators(:,:,i) = (Rot_Matrizen(:,:,i)) * operator * Rot_Matrizen(:,:,i)';
end

blockpairs = zeros(12,2);
count = 1;
for i = 1:24
    for j = i:24
        for k = 1:size(all_operators,3)
            if VariantenSort(:,:,i) - all_operators(:,:,k) * VariantenSort(:,:,j) < 1.e-6
                blockpairs( count, : ) = [i,j];
                count = count +1;
            end
        end
    end
end

blockpairs = unique(blockpairs,'rows');

% ave = zeros(3,3,12);
% epsilon = zeros(12,1);
% a1 = zeros(3,12);
% a2 = zeros(3,12);
% n1 = zeros(3,12);
% n2 = zeros(3,12);
% Q1 = zeros(3,3,12);
% Q2 = zeros(3,3,12);
% 
% for i=1:12
%     ave(:,:,i) = 0.5 *(  VariantenSort(:,:,blockpairs(i,1)) + VariantenSort(:,:,blockpairs(i,2)) )
%     [epsilon(i), a1(i), a2(i), n1(i), n2(i), Q1(:,:,i), Q2(:,:,i) ] = rank_one_kachaturyan( ave(:,:,i) );
% end

fileID = fopen('block_data.txt', 'a');
format_block_variant = '%7.4f \t %7.4f \t %7.4f \t %7.4f \t %7.4f \t %7.4f \n'; %\t %7.4f \t %7.4f \t %7.4f \t \n';
for i=1:12
    % calculate strains (infinite deformation)
    strainSort(:,:,blockpairs(i,1)) = 0.5*( VariantenSort(:,:,blockpairs(i,1))' + VariantenSort(:,:,blockpairs(i,1)) ) - eye(3) ;
    strainSort(:,:,blockpairs(i,2)) = 0.5*( VariantenSort(:,:,blockpairs(i,2))' + VariantenSort(:,:,blockpairs(i,2)) ) - eye(3) ;
    fprintf(fileID,format_block_variant, get_order( strainSort(:,:,blockpairs(i,1)) ) );
    fprintf(fileID,format_block_variant, get_order( strainSort(:,:,blockpairs(i,2)) ) );
end
fclose('all');

    function six_entries = get_order( M )
        six_entries = [M(1,1) M(2,2) M(3,3) M(1,2) M(2,3) M(1,3)]; % Order definition as in my Zebfront Code % M(2,1) M(3,2) M(3,1)];
    end

end


