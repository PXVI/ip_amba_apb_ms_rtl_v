/* -----------------------------------------------------------------------------------
 * Module Name  :
 * Date Created : 10:27:43 IS, 14 January, 2020 [ Tuesday ] 
 *
 * Author       : pxvi
 * Description  :
 * -----------------------------------------------------------------------------------

   MIT License

   Copyright (c) 2020 k-sva

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the Software), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.

 * ----------------------------------------------------------------------------------- */

`define PSTRB_width         4
`define PWDATA_width        8 * `PSTRB_width
`define PRDATA_width        32
`define PADDR_width         32
`define PSELx_width         1

// By default the Memory Depth is 2**MEM_ARRAY_SIZE_INT
`define MEM_ARRAY_SIZE_INT  2

// By Default the Declaration is in Bytes
`ifndef GB
    `ifndef MB
        `ifndef B
            `define B       1
        `else
            `define KB      1
        `endif
    `else
        `define MB          1
    `endif
`else
    `define GB              1
`endif
