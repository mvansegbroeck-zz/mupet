% normalize
function Anorm = normalize(A)
    Anorm = (A - min(min(A)))/(max(max(A)) - min(min(A)));
end