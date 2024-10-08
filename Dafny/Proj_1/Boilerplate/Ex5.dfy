include "Ex3.dfy"

module Ex5 {

  import Ex3=Ex3

  class Set {
    var tbl : array<bool>
    var list : Ex3.Node?

    ghost var footprint : set<Ex3.Node>
    ghost var content : set<nat>

    ghost function Valid() : bool
      reads this, footprint, this.list, this.tbl
    {
      if (list == null)
      then
        footprint == {}
        &&
        content == {}
        &&
        forall i :: 0 <= i < tbl.Length ==> tbl[i] == false
      else
        footprint == list.footprint
        &&
        content == list.content
        &&
        list.Valid()
        &&
        (forall i :: 0 <= i < tbl.Length ==> tbl[i] == (i in content))
        &&
        forall i :: i in this.content ==> i < tbl.Length

    }

    constructor (size : nat)
      ensures Valid()
      ensures Valid() && this.content == {} && this.footprint == {}
      ensures forall i :: 0 <= i < tbl.Length ==> tbl[i] == false
      ensures forall i :: i in this.content ==> i < size
      ensures tbl.Length == size + 1
      ensures fresh(tbl)
    {
      tbl := new bool[size + 1] (_=>false);  
      list := null;
      footprint := {};
      content := {};
    }


    method mem(v: nat) returns (b: bool)
      requires v < tbl.Length  
      requires Valid()
      ensures Valid()
      ensures b == (v in content)
    {      
      b := tbl[v];
    }


    method add(v: nat)
      requires v < tbl.Length
      requires Valid()
      ensures Valid()
      ensures content == old(content) + {v}
      ensures tbl == old(tbl)
      modifies tbl, this
    {
      if (!tbl[v]) {
        tbl[v] := true;

        if (list == null) {
          list := new Ex3.Node(v);
        } else {
          var newNode := list.add(v);  
          list := newNode;
        }

        content := content + {v};
        footprint := if list == null then {} else list.footprint;
      }
    }

    method union(s : Set) returns (r : Set)
      requires Valid()
      requires s.Valid()
      ensures r.Valid()
      ensures r.content == s.content + this.content
 
    {
      var max := max(this.tbl.Length,s.tbl.Length);
      r := new Set(max); 

      ghost var seen : set<int> := {}; 
      var current := this.list;
      while current != null
        invariant r.Valid()
        invariant this.tbl.Length <= r.tbl.Length
        invariant s.tbl.Length <= r.tbl.Length
        invariant fresh(r.tbl)
        invariant current != null ==> current.Valid()
        invariant current != null ==> this.content == seen + current.content
        invariant current == null ==> this.content == seen
        invariant r.content == seen
        decreases if (current != null) then current.footprint else {}
      {
          if current.val < r.tbl.Length && !r.tbl[current.val] {
              r.add(current.val); 
          }
          seen := seen + {current.val}; 
          current := current.next; 
      }

      var other := s.list;
      ghost var seen2 : set<int> := {};
      while other != null
        invariant r.Valid()
        invariant s.tbl.Length <= r.tbl.Length
        invariant fresh(r.tbl)
        invariant other != null ==> other.Valid()
        invariant other != null ==> s.content == seen2 + other.content
        invariant other == null ==> s.content == seen2
        invariant r.content == this.content + seen2
        decreases if (other != null) then other.footprint else {}
      {
          if other.val < r.tbl.Length && !r.tbl[other.val] {
              r.add(other.val);  
          }
          seen2 := seen2 + {other.val};  
          other := other.next;  
      }


    }


    method inter(s: Set) returns (r: Set)
      requires Valid()
      requires s.Valid()
      ensures r.Valid()
      ensures r.content == this.content * s.content 
    {
      var min := min(this.tbl.Length, s.tbl.Length);
      r := new Set(min);


      ghost var seen : set<int> := {};
      var current := this.list;

      while current != null
        invariant r.Valid()
        invariant r.tbl.Length == min + 1
        invariant r.tbl.Length <= this.tbl.Length + 1
        invariant r.tbl.Length <= s.tbl.Length + 1
        invariant fresh(r.tbl)
        invariant current != null ==> current.Valid()
        invariant current != null ==> this.content == seen + current.content
        invariant current == null ==> this.content == seen
        invariant r.content == s.content * seen
        decreases if (current != null) then current.footprint else {}
      {
          if current.val < r.tbl.Length && current.val < s.tbl.Length && s.tbl[current.val] && !r.tbl[current.val] {
              r.add(current.val);
          }
          seen := seen + {current.val};
          current := current.next;
      }
    }


  }

  function max(a:int,b:int):int{
    if a >= b
    then a
    else b
  }

  function min(a:int,b:int):int{
    if a <= b
    then a
    else b
  }

}
