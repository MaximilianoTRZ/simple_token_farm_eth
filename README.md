# Simple DeFi Yield Farming Exercise

Cómo usar Granjas (Yield Farming) en PancakeSwap
https://docs.pancakeswap.finance/products/yield-farming/how-to-use-farms

### Caso de uso

En este ejercicio, implementarás un proyecto DeFi Simple Token Farm.

La Granja debería permitir al usuario hacer depósitos y retiros de un Token LP simulado.
Los usuarios también pueden reclamar las recompensas generadas durante el staking. Estas tokens de recompensa son el token de la plataforma: nombre: "Token DApp", token "DAPP".
El contrato contiene el marco y los comentarios para implementar el contrato. Sigue los comentarios señalados para implementarlo.

El caso de uso del contrato Simple Token Farm es el siguiente:
- Los usuarios depositan Tokens LP `deposit()`
- El usuario puede cosechar o reclamar recompensas `claimRewards()`
- El usuario puede retirar (unstake) todos sus Tokens LP `withdraw()` pero aún reclamar recompensas pendientes
- Cada vez que se actualiza la cantidad de tokens LP apostados, primero se deben recalcular las recompensas
- El propietario de la plataforma puede llamar al método `distributeRewardsAll()` regularmente para actualizar las recompensas pendientes de todos los usuarios que están apostando (staking).

### Contratos

- LPToken.sol: Contrato de token LP, utilizado para staking.
- DappToken.sol: Contrato de token de la plataforma, utilizado como recompensa.
- TokenFarm.sol: El contrato de la Granja.

## Requerimientos
1. Crea un nuevo proyecto *Hardhat*, agrega el contrato proporcionado
2. Implementa todas las funciones, eventos y todo lo mencionado en los comentarios del código en el contrato
3. Despliega los contratos en un entorno local

### Puntos adicionales
Además de las características requeridas, siéntete libre de añadir las características extra para que tu código se destaque entre los demás.

### Bonus: 1 Modificador

Crea funciones `modifier()` que validen:
    1. si el llamante de la función es un usuario que está apostando
    2. si el llamante de la función es el propietario del contrato
Añade el modificador en las funciones que lo requieran.

### Bonus: 2 Estruct

Crea una `Struct{}` que contenga la información de staking del usuario y reemplace los siguientes `mapping()`

```
mapping(address => uint256) public stakingBalance;
mapping(address => uint256) public checkpoints;
mapping(address => uint256) public pendigRewards;
mapping(address => bool) public hasStaked;
mapping(address => bool) public isStaking;
```

Por un nuevo `mapping()` de `(address => structUser)`.
Modifica las funciones correspondientes de acuerdo a este nuevo `mapping()`.

### Bonus: 3 Tests

Crea un archivo de tests para el contrato SimpleBank que te permita probar:
1. Acuñar Tokens LP para un usuario y hacer un depósito de esos tokens
2. La plataforma distribuye correctamente las recompensas a todos los usuarios que están apostando
3. El usuario reclama recompensas y verifica si se transfirieron exitosamente a su cuenta
4. El usuario des-apuesta todos los tokens LP depositados y reclama recompensas pendientes, si las hay

### Bonus: 4 Recompensas variables por bloque
1. Transforma las recompensas por bloque en un rango, permite al propietario cambiar ese valor.

### Bonus: 5 Tarifa de retiro ( Withdrawal fee)
1. Cobra una tarifa al momento de reclamar las recompensas.
2. Añade una función para que el propietario pueda retirar esa tarifa.

### Bonus: 6 Proxy (nuevo proyecto)
1. Implementa el extra 5 como una versión V2 de nuestro contrato de agricultura
O
2. Nuestra plataforma ha crecido y vamos a implementar granjas para más tipos de tokens LP. ¿Cómo podemos solucionar el despliegue de nuevos contratos de agricultura ahorrando gas?
