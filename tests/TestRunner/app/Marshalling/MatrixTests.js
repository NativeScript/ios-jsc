describe(module.id, function () {
    it("simd_float4x4Matrix", function(){
        var simdMatrix = getMatrixFloat4x4();
        for (var i = 0; i < 16; i++) {
          expect(simdMatrix.columns[i%4][Math.floor(i/4)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_float4x3Matrix", function(){
        var simdMatrix = getMatrixFloat4x3();
        for (var i = 0; i < 12; i++) {
          expect(simdMatrix.columns[i%4][Math.floor(i/4)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_float4x2Matrix", function(){
        var simdMatrix = getMatrixFloat4x2();
        for (var i = 0; i < 8; i++) {
          expect(simdMatrix.columns[i%4][Math.floor(i/4)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_float3x4Matrix", function(){
        var simdMatrix = getMatrixFloat3x4();
        for (var i = 0; i < 12; i++) {
          expect(simdMatrix.columns[i%3][Math.floor(i/3)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_float3x3Matrix", function(){
        var simdMatrix = getMatrixFloat3x3();
        for (var i = 0; i < 9; i++) {
          expect(simdMatrix.columns[i%3][Math.floor(i/3)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_float3x2Matrix", function(){
        var simdMatrix = getMatrixFloat3x2();
        for (var i = 0; i < 6; i++) {
          expect(simdMatrix.columns[i%3][Math.floor(i/3)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_float2x4Matrix", function(){
        var simdMatrix = getMatrixFloat2x4();
        for (var i = 0; i < 8; i++) {
          expect(simdMatrix.columns[i%2][Math.floor(i/2)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_float2x3Matrix", function(){
        var simdMatrix = getMatrixFloat2x3();
        for (var i = 0; i < 6; i++) {
          expect(simdMatrix.columns[i%2][Math.floor(i/2)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_float2x2Matrix", function(){
        var simdMatrix = getMatrixFloat2x2();
        for (var i = 0; i < 4; i++) {
          expect(simdMatrix.columns[i%2][Math.floor(i/2)].toFixed(4)).toBe((i*3.1415).toFixed(4));
        }
     });

     it("simd_double4x4Matrix", function(){
         var simdMatrix = getMatrixDouble4x4();
         for (var i = 0; i < 16; i++) {
           expect(simdMatrix.columns[i%4][Math.floor(i/4)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("simd_double4x3Matrix", function(){
         var simdMatrix = getMatrixDouble4x3();
         for (var i = 0; i < 12; i++) {
           expect(simdMatrix.columns[i%4][Math.floor(i/4)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("simd_double4x2Matrix", function(){
         var simdMatrix = getMatrixDouble4x2();
         for (var i = 0; i < 8; i++) {
           expect(simdMatrix.columns[i%4][Math.floor(i/4)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("simd_double3x4Matrix", function(){
         var simdMatrix = getMatrixDouble3x4();
         for (var i = 0; i < 12; i++) {
           expect(simdMatrix.columns[i%3][Math.floor(i/3)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("simd_double3x3Matrix", function(){
         var simdMatrix = getMatrixDouble3x3();
         for (var i = 0; i < 9; i++) {
           expect(simdMatrix.columns[i%3][Math.floor(i/3)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("simd_double3x2Matrix", function(){
         var simdMatrix = getMatrixDouble3x2();
         for (var i = 0; i < 6; i++) {
           expect(simdMatrix.columns[i%3][Math.floor(i/3)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("simd_double2x4Matrix", function(){
         var simdMatrix = getMatrixDouble2x4();
         for (var i = 0; i < 8; i++) {
           expect(simdMatrix.columns[i%2][Math.floor(i/2)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("simd_double2x3Matrix", function(){
         var simdMatrix = getMatrixDouble2x3();
         for (var i = 0; i < 6; i++) {
           expect(simdMatrix.columns[i%2][Math.floor(i/2)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("simd_double2x2Matrix", function(){
         var simdMatrix = getMatrixDouble2x2();
         for (var i = 0; i < 4; i++) {
           expect(simdMatrix.columns[i%2][Math.floor(i/2)].toFixed(4)).toBe((i*3.1415).toFixed(4));
         }
      });

      it("SCNMatrix4FromMat4", function() {
         const m1 = getMatrixFloat4x4();
         const m2 = _SCNMatrix4FromMat4(m1);

         for (let col = 0; col < 4; col++) {
             for (let row = 0; row < 4; row++) {
                 expect(m2[`m${col+1}${row+1}`].toFixed(4)).toBe((m1.columns[col][row]).toFixed(4));
             }
         }
     });

     it("SCNMatrix4ToMat4", function() {
         const m1 = {};
         for (let col = 0; col < 4; col++) {
             for (let row = 0; row < 4; row++) {
                 m1[`m${col+1}${row+1}`] = 3.1415*(row*4 + col);
             }
         }

         const m2 = _SCNMatrix4ToMat4(m1);

         for (let col = 0; col < 4; col++) {
             for (let row = 0; row < 4; row++) {
                 expect((m2.columns[col][row]).toFixed(4)).toBe(m1[`m${col+1}${row+1}`].toFixed(4));
             }
         }
     });
 });
