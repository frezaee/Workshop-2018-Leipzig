
newPackage(
     "Chow",
     Version => "0.5",
     Date => "22 November  2009",
     Authors => {{
	       Name => "Diane Maclagan",
       	       Email => "D.Maclagan@warwick.ac.uk",
	       HomePage => "http://www.warwick.ac.uk/staff/D.Maclagan"}},
     Headline => "Chow computations for toric varieties",
     DebuggingMode => true,
     PackageImports => {"FourierMotzkin", "Polyhedra"},
     PackageExports => {"NormalToricVarieties"}
     )

export { 
     "AA",
     "nefCone",
     "nefCone2",
     "effCone",
     "isContainedCones",
     "nefEqualsIntersection",
     "chowGroupBasis",
     "chowGroup",
     "Lcone",
     "Lconeb",
     "LconevsNef",
     "IntersectionRing",
     "intersectionRing"
     }

protect ChowGroupBas 
protect AmbientRing

---------------------------------------------------------------------------
-- CODE
---------------------------------------------------------------------------

--Is A contained in B?
--A, B lists
isContained = (A,B)->(
     all(A,i->member(i,B))
     )

--Index of lattice generated by rays of tau in the lattice generated by the 
--rays of the Normal ToricVariety X 
latticeIndex = (tau, X) ->(
      A:=matrix rays X;
      B:=A^tau;
      brank:=rank B;
      if brank < rank A then (
	   K:=gens kernel B;
	   C:=gens kernel transpose(A*K);
	   A=transpose(C)*A;
      );
      if not((rank A)==brank) then error("Something's wrong here");
      a:=(flatten entries mingens minors(brank,A))_0;
      b:=(flatten entries mingens minors(brank,B))_0;
      return(lift(b/a,ZZ));
)     
     
     
--Greg says this has been superseded - see orbits
--cones (ZZ, NormalToricVariety) :=  List => (i,X) ->(
-- cones (ZZ, NormalToricVariety) :=  (i,X) ->(
--      if not X.cache.?cones then X.cache.cones = new MutableHashTable;
--      if not X.cache.cones#?i then (
-- 	  if isSimplicial(X) then (
-- 	      X.cache.cones#i = unique flatten for sigma in max X  list subsets(sigma,i);
-- 	  )
--      	  else (     
-- 	       F:=fan X;
-- 	       Conesi:=cones(i,F);
-- 	       X.cache.cones#i=apply(Conesi,C->(
-- 		    RaysC := entries transpose rays C;
-- --This next bit to be changed when Rene fixes Polyhedra
-- RaysC2:=apply(RaysC,i->(apply(i,j->(lift(j,ZZ)))));
-- RaysC=RaysC2;		    
--      	       	    P:=positions(rays X, i->member(i,RaysC));
-- 		    P
-- 	       ));
--      	  );
--      );
--      X.cache.cones#i=sort X.cache.cones#i;
--      return X.cache.cones#i;
-- ) 




--Is cone with generators given by columns of M contained in cone generated
--by columns of N?
--Temporarily assuming full dimensional
--(ie this is a hack)
isContainedCones= (M,N) ->(
          Nfacets:=(fourierMotzkin(N))#0;
	  nonneg := flatten entries ((transpose M)* Nfacets);
	  if max(nonneg)>0 then return(false) else return(true);
);     

--Intersect the cones given by the columns of M and the columns of N
--Temporarily assuming full dimensional
--(ie this is a hack)
intersectCones=(M,N)-> (
        Nfacets:=(fourierMotzkin(N))#0;
        Mfacets:=(fourierMotzkin(M))#0;
	return( (fourierMotzkin(Nfacets | Mfacets))#0);
);	

--Chow
-- i is codim
chowGroup=(i,X) -> ( 
     if i>dim(X) then error("i > dim(X)");
     if not(X.cache.?Chow) then X.cache.Chow = new MutableHashTable;
     if not(X.cache.Chow#?i) then (
     n:=dim X;
     -- Get the faces of dim i, i-1
     sigmaCodimi := orbits(X,n-i);
     if i == 0 then (
	if #sigmaCodimi == 0 then (
	    sigmaCodimi = {{}};
	);
        X.cache.Chow#i = ZZ^(#sigmaCodimi);
	return X.cache.Chow#i;   
     ) else tauCodimiminus1 := orbits(X,n-i+1);
     if i == 1 then (
	 tauCodimiminus1 = {{}};
     );
     if #tauCodimiminus1 > 0 then (
         --Create the relations (Fulton-Sturmfels eqtn 1, p337)
     Relns:=apply(tauCodimiminus1, tau -> (
     	  Mtau:= entries transpose gens kernel (matrix rays X)^tau;	  
	  TauRelns:=apply(Mtau, u->(
     	       reln:= apply(sigmaCodimi,sigma->(
     	       	    relnsigma:=0;
		    if isContained(tau,sigma) then (
     	       	    	  j:=position(sigma, k->(not(member(k,tau))));
			  nvect:=(rays X)#(sigma#j);
      	       	    	  udotn:=0;
		      	  for k from 0 to #u-1 do
			       udotn=udotn+(u#k)*(nvect#k);
 		          nsigmamult:=latticeIndex(append(tau,sigma#j) ,X) // latticeIndex(tau,X);
			  relnsigma=udotn // nsigmamult;
		    )
	       	    else (	 
		      relnsigma=0;
		    );
	       	    relnsigma
	       ));
	       reln
     	  ));
     	  TauRelns
     ));
     Relns=flatten Relns;
     X.cache.Chow#i = prune coker transpose matrix Relns;
     )
     else X.cache.Chow#i = ZZ^(#sigmaCodimi);
     );
     X.cache.Chow#i
);	 
	 

--isCartier = D -> (
     
--)     


-- intersect (List, ZZ, List, NormalToricVariety) := List => (D, k, tau, X)  -> (
--      if isCartier(D) then (
--      n:=dim X;
--      Zorder := cones(n-k,X);
--      outputCones := cones(n-k+1, X);
--      --First rewrite D so that it is not supported on V(tau)
--      --????
--      --Then do the intersection 
--      DdotTau:=apply(outputCones, sigma -> (
--      	  if not(isContained(tau,sigma)) then 0
-- 	  else (
     	       	            	       	       
--      	  )
--      ));
--      return(DdotTau);
--      )
--      else (
-- 	  <<"D is not a Cartier divisor"<<endl;
-- --???should error trap properly
--      );
-- );     

--Intersect V(sigma) and V(tau) using the SR formulation.
--Not sure about the use of this.
-- intersect ( List, List, NormalToricVariety, ) := MutableHashTable =>( sigma, tau, X) -> (
--       if not isSimplicial X then error("Not implemented yet");
--       --We'll turn sigma into a product of torus-invariant divisors
--       --and do the intersection one-by-one
--       I:=SR(X);
--       R:=ring I;
--       m:=1_R;
--       for i in sigma do (
-- 	   m=m*R_i;
--       );
--       for i in tau do (
-- 	   m=m*R_i;
--       );
--       rem:= m % I;
--       rem   		   
-- );      


--Create SR ideal
intersectionRing = method()
intersectionRing(NormalToricVariety,Ring) := (X,S) -> (
     if (not X.cache.?IntersectionRing) or (not coefficientRing(X.cache.IntersectionRing) === S) then (
 	 z:=symbol z;
     	 R:=S[z_0..z_(#(rays X)-1)];
       	 I:= ideal apply(max X, sigma->(
	       	    mono:=1_R;
	       	    for j from 0 to #(rays X)-1 do 
		        if not(member(j,sigma)) then mono=mono*R_j;
	       	    mono
		    ));
     	 squaresIdeal:=ideal apply(gens R, xx->xx^2);       
     	 I=ideal flatten entries ((gens (squaresIdeal : I)) % squaresIdeal);
     	 I=I+ ideal apply(transpose rays X, a->(
	       genJ:=0_R;
	       for j from 0 to #a-1 do (
		    genJ=genJ+a#j*R_j;
	       );
	       genJ    
     	 ));
     X.cache.IntersectionRing=R/(ideal mingens I);
     X.cache.AmbientRing = R;
     );
     X.cache.IntersectionRing
);
intersectionRing(NormalToricVariety) := X -> (intersectionRing(X,QQ));

--Compute a basis for the Chow ring
chowGroupBasis = method()
chowGroupBasis(NormalToricVariety,ZZ) := (X,i) -> (
     if not X.cache.?ChowGroupBas then
     	  X.cache.ChowGroupBas = new MutableHashTable;
     R:=intersectionRing(X);
     if not X.cache.ChowGroupBas#?i then 	  
          X.cache.ChowGroupBas#i=flatten entries lift(basis(dim X -i,R),X.cache.AmbientRing);
     return(X.cache.ChowGroupBas#i);
);
chowGroupBasis(NormalToricVariety) := X -> (for i from 0 to dim X list chowGroupBasis(X,i))


--Code to compute the cone of nef cycles

--Currently returns a rather arbitrary  basis for the ith Chow group 
-- and then a matrix whose columns represent elements there
--generating the cone of nef i-cycles
--(Caveat: this is dimension i, so codimension n-i)

nefCone=(i,X)->(
     if not isSmooth(X) then error("Not implemented yet");
     n:=dim X;
     Conesi:=orbits(X,n-i);
     --Get intersection ring
     I:=ideal(intersectionRing(X));
     R:=X.cache.AmbientRing;
     --Now create the multiplication map
     --First get a basis for chowGroup_i
     chowBas:=chowGroupBasis(X,i);
     mono:=1_R;
     for i in (max X)_0 do mono=mono*R_i;
     topBas1:=mono % I;
     Mat:=matrix unique apply(chowBas,m->(
	       apply(Conesi,sigma->(
			 mono:=1_R;
			 for j in sigma do mono=mono*R_j;
     	       	    	 --Assumes R has coefficients in QQ
     	       	    	 lift(((m*mono) % I)/topBas1, QQ)
     	       ))
     ));
--Temporarily assuming that cone is full-dimensional - is it always???
--<<"Got this far with nefCone"<<endl;
--<<rank source Mat <<"    "<<rank target Mat <<endl;
    matDual:=-1*(fourierMotzkin Mat)#0;
    return(matDual);
);


--Code to compute the cone nef^k_i, which is the cone of all
-- codimension k-cycles that intersect every effective i-dimensional
-- cycle in effective cycles.
--Currently returns a rather arbitrary  basis for the codim-k Chow group 
-- and then a matrix whose columns represent generators for this 
--cone

nefCone2=(k,i,X)->(
     if k>i then error("i must be at least k");
     if not isSmooth(X) then error("Not implemented yet");
     n:=#((rays X)#0);
     Conesk:=orbits(X,k);
     --Get intersection ring
     I:=ideal(intersectionRing(X));
     R:= X.cache.AmbientRing;
     --Now create the multiplication map
     --First get a basis for chowGroup_k
     if not X.cache.?ChowGroupBas then
     	  X.cache.ChowGroupBas = new MutableHashTable;
     if not X.cache.ChowGroupBas#?(n-k) then 	  
          X.cache.ChowGroupBas#(n-k)=flatten entries lift(basis(k,R/I),R);
     --We'll create a bas times Conesi matrix with (j,k) entry bas#j * Conesi #k
     --???need to edit from here.	  
     mono:=1_R;
     for i in (max X)_0 do mono=mono*R_i;
     topBas1:=mono % I;
     Mat:=matrix unique apply(X.cache.ChowGroupBas#(n-k),m->(
	       apply(Conesk,sigma->(
			 mono:=1_R;
			 for j in sigma do mono=mono*R_j;
     	       	    	 --Assumes R has coefficients in QQ
     	       	    	 lift(((m*mono) % I)/topBas1, QQ)
     	       ))
     ));
--Temporarily assuming that cone is full-dimensional - is it always???
     matDual:=-1*(fourierMotzkin Mat)#0;
     return(matDual);
);


--Compute the effective cone of i cycles in X
-- i is the dimension?
effCone=(i,X)->(
     if not isSmooth(X) then error("Not implemented yet");     
     n:=dim X;
     --Get intersection ring
     I:=ideal(intersectionRing(X));
     R:=X.cache.AmbientRing;
     if not X.cache.?ChowGroupBas then
     	  X.cache.ChowGroupBas = new MutableHashTable;
     if not X.cache.ChowGroupBas#?i then 	  
          X.cache.ChowGroupBas#i=flatten entries lift(basis(n-i,R/I),R);
     --j=n-i
     Conesj:=orbits(X,i);
     EffMat:=transpose matrix apply(Conesj,sigma->(
    	  mono:=1_R;
	  for j in sigma do mono=mono*R_j;
     	  mono=mono % I;
	  apply(X.cache.ChowGroupBas#i,m->(coefficient(m,mono)))
     ));	  
     return(EffMat);
);


---------------------------------------------------------------------------
-- DOCUMENTATION
---------------------------------------------------------------------------
beginDocumentation()

doc ///
    Key
        Chow
    Headline
        intersection theory for normal toric varieties
    Description
        Text
            This is a subpackage for eventual inclusion into Greg Smith's NormalToricVarieties package
        Text 
            It contains routines to do compute the Chow ring and groups of a normal toric variety, plus compute the nef and effective cones of cycles.
///


doc ///
  Key
      chowGroup
  Headline
      Chow rings for toric varieties
  Usage
      chowGroup(i,X)
  Inputs
      i:ZZ
      X:NormalToricVariety
  Outputs
      :Module
         the codim-i Chow group $A^i(X)$, an abelian group (a  ZZ-module)
  Description
      Text
         This procedure computes the ith Chow group of the NormalToricVariety X. It produces it as the cokernel of a matrix, 
	 following the description given in Proposition 2.1 of Fulton-Sturmfels
	 Intersection Theory on toric varieties (Topology, 1996). 
      Text
         It is cached in X.cache.Chow#i.
      Text 
         ???say something about pruning map.
      Text 
         These groups are all one-dimensional for projective space.  
      Example 
         X = projectiveSpace 4
	 rank chowGroup(1,X) 
	 rank chowGroup(2,X) 
	 rank chowGroup(3,X)
      Text
         We next consider the blow-up of P^3 at two points.
      Example
         X=normalToricVariety({{1,0,0},{0,1,0},{0,0,1},{-1,-1,-1},{1,1,1}, {-1,0,0}}, {{0,2,4},{0,1,4},{1,2,4},{1,2,5},{2,3,5},{1,3,5},{0,1,3},{0,2,3}})
         chowGroup(1,X) 
         chowGroup(2,X)
/// 	 

doc ///
    Key
        chowGroupBasis
    Headline
        the basis of the Chow group in dim i
    Usage
        chowGroupBasis(X) or chowGroupBasis(X,i)
    Inputs
        X:NormalToricVariety
	i:ZZ
    Outputs
        :Module
	   a basis for the ith Chow group (a ZZ-module)
    Description
       Text 
         This method returns the cached basis for the Chow group of dimension-i cycles on X.  
	 If called without i, it returns a list so that chowGroupBasis(X)#i = chowGroupBasis(X,i).
       Example
         X = projectiveSpace 4 
         chowGroupBasis(X)
       Example
         X=normalToricVariety({{1,0,0},{0,1,0},{0,0,1},{-1,-1,-1},{1,1,1}, {-1,0,0}}, {{0,2,4},{0,1,4},{1,2,4},{1,2,5},{2,3,5},{1,3,5},{0,1,3},{0,2,3}})
         chowGroupBasis(X)
         chowGroupBasis(X,2) -- a basis for divisors on this threefold
///


doc ///
     Key
       effCone
     Headline
       the cone of effective T-invariant i-cycles  
     Usage
       effCone(i,X)
     Inputs
       i:ZZ
       X:NormalToricVariety
     Outputs
       :Matrix
         whose columns are the generators for the cone of effective i-cycles
     Description
       Text
         This is currently only implemented for smooth toric varieties.
         The columns should be given in a basis for the i-th Chow group
         recorded in X.cache.ChowGroupBas#i and accessed via chowGroupBasis(X).
       Example
         X = projectiveSpace 4
         effCone(2,X)
       Example 
         X = hirzebruchSurface 1;
         effCone(1,X)
///   


doc ///
     Key
       nefCone
     Headline
       the cone of nef T-invariant i-cycles   
     Usage
       nefCone(i,X)
     Inputs
       i:ZZ
       X:NormalToricVariety
     Outputs
       :Matrix
         whose columns are the generators for the cone of nef i-cycles
     Description
       Text
         A cycle is nef if it intersects every effective cycle of
         complementary dimension nonnegatively.
	 This is currently only implemented for smooth toric varieties.
	 The columns are given in a basis for the i-th Chow group
         recorded in X.cache.ChowGroupBas#i and accessed via chowGroupBasis(X).
       Example
         X=projectiveSpace 4
         nefCone(2,X)
       Example 
         X=hirzebruchSurface 1;
	 nefCone(1,X)
///        
     
     
     
doc ///
     Key
       intersectionRing
       (intersectionRing,NormalToricVariety)
       (intersectionRing,NormalToricVariety,Ring)
     Headline
       compute the Chow ring of a smooth toric variety
     Usage
       intersectionRing(X)
       intersectionRing(X,S)
     Inputs 
       X:NormalToricVariety
       S:Ring
     Outputs
       :Ideal
         which defines the relations on the Chow ring of X
     Description
       Text 
         The ring of the ideal has one generator for each ray of X, and
         the ideal is the ideal given in the Stanley-Reisner presentation of
         the cohomology ring of X.
         This assumes that X is smooth.  Eventually it will be
         implemented for simplicial toric varieties.
       Example
         X = projectiveSpace 2
         R = intersectionRing X
         for i from 0 to 2 do <<hilbertFunction(i,R)<<endl
       Text 
         Next we consider the blow-up of P^3 at 2 points.
       Example 
         X=normalToricVariety({{1,0,0},{0,1,0},{0,0,1},{-1,-1,-1},{1,1,1}, {-1,0,0}}, {{0,2,4},{0,1,4},{1,2,4},{1,2,5},{2,3,5},{1,3,5},{0,1,3},{0,2,3}})
	 R = intersectionRing X
         hilbertFunction(1,R)
       Text 
         Note that the degree-one part of the ring has dimension the Picard-rank, as expected.
       Text
         Note that a coefficient ring can also be specified. By default, the coefficient ring is the rational numbers.
       Example
         X = projectiveSpace 2
	 R = intersectionRing(X,ZZ)
	 for i from 0 to 2 do <<hilbertFunction(i,R)<<endl 

///

doc ///
     Key
        isContainedCones
     Headline
        decide if one cone is contained inside another
     Usage
        isContainedCones(M,N)
     Inputs
        M:Matrix
	N:Matrix
     Outputs
       :Boolean
          Returns true if the cone generated by the columns of the matrix
     Description
        Text
          M is contained in the cone generated by the columns of the matrix N.
          This currently assumes that both cones are full-dimensional, and is implemented in 
          a somewhat hackish manner.
///
---------------------------------------------------------------------------
-- TEST
---------------------------------------------------------------------------

--Replace X by something more interesting
TEST ///
X=projectiveSpace 4
assert(rank chowGroup(3,X) == rank chowGroup(1,X))
assert(rank chowGroup(3,X) == rank picardGroup X)
/// 

TEST ///
A=sort apply(3,i->random(5))
X=kleinschmidt(6,A)
R=QQ[x,y]
I=ideal(x^4,y^4)
for i from 0 to 6 do
     assert(rank chowGroup(i,X) == hilbertFunction(i,R/I))
///

--do P2 blown up at a point Z[H,E]/(H^3, E^2 + H^2, E^3)
TEST ///
rayList={{1,0},{0,1},{-1,-1},{0,-1}}
coneList={{0,1},{1,2},{2,3},{3,0}}
X = normalToricVariety(rayList,coneList)
assert(rank chowGroup(0,X) == 1)
assert(rank chowGroup(1,X) == 2)
assert(rank chowGroup(2,X) == 1)
///


--do P1xP1 -> P3 Z[H,K]/(H^2, K^2)
TEST ///
rayList={{1,0},{0,1},{-1,0},{0,-1}}
coneList={{0,1},{1,2},{2,3},{3,0}}
X = normalToricVariety(rayList,coneList)
assert(rank chowGroup(1,X) == 2)
assert(rank chowGroup(2,X) == 1)
assert(rank chowGroup(0,X) == 1)
///


end

---------------------------------------------------------------------------
-- SCRATCH SPACE
---------------------------------------------------------------------------
 
restart
loadPackage "Chow"
--X is blow-up of P^3 at two points
raysX={{1,0,0},{0,1,0},{0,0,1},{-1,-1,-1},{1,1,1}, {-1,0,0}};
Sigma={{0,2,4},{0,1,4},{1,2,4},{1,2,5},{2,3,5},{1,3,5},{0,1,3},{0,2,3}};
X=normalToricVariety(raysX,Sigma);

--X is the blow-up of P^4 at 2 points

raysX={{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1},{-1,-1,-1,-1},{1,1,1,1},{-1,0,0,0}};
Sigma={{0,1,2,4},{0,1,3,4}, {0,2,3,4}, {0,1,2,5}, {0,1,3,5},
{0,2,3,5}, {1,2,3,5}, {1,2,3,6}, {1,2,4,6}, {1,3,4,6}, {2,3,4,6}};
X=normalToricVariety(raysX,Sigma);

--Y is the blow-up of P^4 at 1 point
raysY={{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1},{-1,-1,-1,-1},{1,1,1,1}};
Sigma2 = {{0,1,2,4}, {0,1,3,4}, {0,2,3,4}, {1,2,3,4}, {0,1,2,5}, {0,1,3,5},
     {0,2,3,5}, {1,2,3,5}};
Y=normalToricVariety(raysY,Sigma2);

-- document { 
--      Key => {(cones, (ZZ, NormalToricVariety)},
--      Headline => "the i dimension cones of the fan",
--      Usage => "cones(i,X)"
--      Inputs => {
-- 	  "i" => "a nonnegative integer",
-- 	  "X" => NormalToricVariety
-- 	  },
--      Outputs => {},

--      EXAMPLE lines ///
-- 	  PP1 = projectiveSpace 1;
-- 	  ///,
--      SeeAlso => {normalToricVariety, weightedProjectiveSpace,
-- 	  (ring,NormalToricVariety), (ideal,NormalToricVariety)}
--      }     


--stellarSubdivision bug/features
----doesn't add new ray at end
----when adding ray that is already there it doesn't realize it
----Also creates X.cache.cones (name clash)

--For example - try blow-up of P4 at 2 points



W=sort apply(5,i->random(7)+1);
while not all(subsets(W,4), s -> gcd s === 1) do 
      W=sort apply(5,i->random(7)+1);
X=resolveSingularities weightedProjectiveSpace(W);
summ=0;
R = intersectionRing(X);
I = ideal(R);
scan(5,i->(summ=summ+(hilbertFunction(i,R/I)-rank(chowGroup(i,X)))^2;));
<<summ<<endl;


uninstallPackage "Chow"
restart
loadPackage "Chow"
installPackage "Chow"
check "Chow"
