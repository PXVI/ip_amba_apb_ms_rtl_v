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

// Declaration Parameters
// ----------------------
`define IP_AMBA_APB_SLAVE_PARAM_DECL #( \
                                        parameter PRDATA_width = `PRDATA_width, \
                                        parameter PWDATA_width = `PWDATA_width, \
                                        parameter PSTRB_width = `PSTRB_width, \
                                        parameter PADDR_width = `PADDR_width, \
                                        parameter PSELx_width = `PSELx_width, \
                                        parameter WORD_LENGTH = `PRDATA_width, \
                                        parameter MEM_DEPTH = `MEM_ARRAY_SIZE_INT, \
                                        parameter APB_BASE_ADDR = `APB_Base_Addr \
                                        )
