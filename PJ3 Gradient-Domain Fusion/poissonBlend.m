function output = poissonBlend(source,mask,target)
% construct the mask
output = zeros(size(target));
[ry,rx] = find(mask);
len = length(ry);
vmask = zeros(size(mask,1),size(mask,2));
for i = 1:len
     vmask(ry(i),rx(i)) = i;
end
% figure(1),imagesc(vmask),axis image;

for ch = 1:3
    % prepare the single channel and initialize
    back = target(:,:,ch);
    fore = source(:,:,ch);
    e = 1;
    A = sparse([],[],[],len*4+1,len);
    b = sparse([],[],[],len*4+1,len);
    
    % pixels in region
    for i = 1:len
        x = rx(i);
        y = ry(i);
        %up
        if vmask(y-1,x) == 0
            A(e, vmask(y,x)) =1;
            b(e) = fore(y,x) - fore(y-1,x) + back(y-1,x) ;
        else
            A(e, vmask(y,x)) =1;
            A(e, vmask(y-1,x)) = -1;
            b(e) = fore(y,x) - fore(y-1,x);
        end
        e = e+1;
        % down
        if vmask(y+1,x) == 0
            A(e, vmask(y,x)) =1;
            b(e) = fore(y,x) - fore(y+1,x) + back(y+1,x) ;
        else
            A(e, vmask(y,x)) =1;
            A(e, vmask(y+1,x)) = -1;
            b(e) = fore(y,x) - fore(y+1,x);
        end
        e = e+1;
        % left
        if vmask(y,x-1) == 0
            A(e, vmask(y,x)) =1;
            b(e) = fore(y,x) - fore(y,x-1) + back(y,x-1) ;
        else
            A(e, vmask(y,x)) =1;
            A(e, vmask(y,x-1)) = -1;
            b(e) = fore(y,x) - fore(y,x-1);
        end
        e = e+1;
        % right
        if vmask(y,x+1) == 0
            A(e, vmask(y,x)) =1;
            b(e) = fore(y,x) - fore(y,x+1) + back(y,x+1) ;
        else
            A(e, vmask(y,x)) =1;
            A(e, vmask(y,x+1)) = -1;
            b(e) = fore(y,x) - fore(y,x+1);
        end
        e = e+1;
    end
    A(e, vmask(y,x)) = 1;
    b(e) = fore(y,x);    
    
    % compute the region
    A = sparse(A);
    v = A\b;
    for i = 1:len
        back(ry(i),rx(i)) =v(i);
    end
    
    % reconstruct the channel
    output(:,:,ch) = back;
end
