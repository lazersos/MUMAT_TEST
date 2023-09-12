
FC=mpif90
COMP_OPT = -O0 -fexternal-blas -fbacktrace -fcheck=all -g

LIBSTELL_INC = -I$(STELLOPT_PATH)/LIBSTELL/Release
LIBSTELL_LIB = $(STELLOPT_PATH)/LIBSTELL/Release/libstell.a

MAGTENSE_DIR = $(MAGTENSE_PATH)
MAGTENSE_INC = -I$(MAGTENSE_DIR)/source/NumericalIntegration/NumericalIntegration/ \
    -I$(MAGTENSE_DIR)/source/TileDemagTensor/TileDemagTensor/ \
    -I$(MAGTENSE_DIR)/source/DemagField/DemagField/ 
MAGTENSE_LIB = $(MAGTENSE_DIR)/source/NumericalIntegration/NumericalIntegration/libNumericalIntegration.a \
    $(MAGTENSE_DIR)/source/TileDemagTensor/TileDemagTensor/libTileDemagTensor.a \
    $(MAGTENSE_DIR)/source/DemagField/DemagField/libDemagField.a 


FFLAGS= $(LIBSTELL_INC) $(MAGTENSE_INC)
LDFLAGS=$(LIBSTELL_LIB) $(MAGTENSE_LIB)

OBJ=mumaterial_test.o

EXE=xmumat_test

%.o: %.f90
	$(FC) -c -o $@ $< $(FFLAGS) $(COMP_OPT)

$(EXE): $(OBJ)
	$(FC) -o $@ $^ $(LDFLAGS) $(LIBS) $(COMP_OPT)

run: $(EXE)
	./$(EXE) >& log.txt

clean:
	rm *.o $(EXE)
