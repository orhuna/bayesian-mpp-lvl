function k = RemainingPatchFace(IS,ind_eraser)
%RemainingPatchFace finds the part of a surface that is partially
%unexplained with proposed fit surface
k = IS ;

face_erase = [] ;
for i = 1 : length(ind_eraser)
    face_erase = [face_erase ; mod( find(k.faces(:)==ind_eraser(i)) , length(IS.faces) ) ] ;
end

face_erase = sort(unique(face_erase));
face_erase(face_erase==0) = length(IS.faces) ;

k.faces(face_erase,:) = [] ;
k.vertices(ind_eraser,:) = [];


    for i = 1 : size(k.vertices,1)
        association(i) = find( ismember(IS.vertices, k.vertices(i,:),'rows') ) ;
        k.faces( k.faces == association(i) ) = i ;
    end