// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./DappToken.sol";
import "./LPToken.sol";

/**
    Una granja de tokens súper simple 
*/
contract TokenFarm {

    // Variables de estado

    string public name = "Simple Token Farm";

    address public owner;   
    DappToken public dappToken; // token de recompensa de la plataforma simulada
    LPToken public lpToken; // Token LP simulado staked por usuarios

    // recompensas por bloque
    uint256 public constant REWARD_PER_BLOCK = 1e18;

    // lista iterable de usuarios que hacen staking
    address[] public stakers;

    // información de staking y recompensas de los usuarios
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public pendigRewards;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    // Eventos - añade eventos según sea necesario

    
    /**
        constructor
     */ 
    constructor(DappToken _dappToken, LPToken _lpToken) {
        // Establece al dueño como el creador de este contrato
        // Establece la instancia de los contratos Dapp y LP desplegados
    }

    /**
     @notice Depositar
     Los usuarios depositan Tokens LP
     */
    function deposit(uint256 _amount) public {
        // Requiere cantidad mayor a 0

        // Transfiere Tokens LP simulados a este contrato para stakear

        // Actualiza el balance de staking

        // Añade usuario al array de stakers solo si no han staked ya

        // Actualiza el estado del staking
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;

        // número de bloque de punto de control
        if (checkpoints[msg.sender] == 0) {
            checkpoints[msg.sender] = block.number;
        }

        // calcula las recompensas
        distributeRewards();

        // emite algún evento
    }

    /**
     @notice Retirar
     Unstaking Tokens LP (Retirar todos los Tokens LP)
     */
    function withdraw() public {
        // verifica si el remitente está staking

        // Obtiene el balance de staking
        uint256 balance =;

        // Requiere cantidad mayor a 0

        // calcula recompensas antes de restablecer el balance de staking
        distributeRewards();

        // Restablece el balance de staking

        // Actualiza el estado de la staking

        // emite algún evento

        // Transfiere Tokens LP al usuario
    }

    /**
     @notice Reclamar Recompensas
     Los usuarios reclaman recompensas pendientes
     Las recompensas pendientes se acuñan al usuario
     */
    function claimRewards() public {
        // busca recompensas pendientes
        uint256 pendigAmount =;

        // verifica si el usuario tiene recompensas pendientes

        // restablece el balance de recompensas pendientes

        // acuña tokens de recompensas al usuario
        dappToken.mint();

        // emite algún evento
    }

    /**
     @notice Distribuir recompensas 
     Distribuye recompensas a todos los usuarios staking
     */
    function distributeRewardsAll() external {
        // Solo el dueño puede llamar a esta función

        // establece recompensas a todos los stakers
        // en este caso, la lista iterable de usuarios staking podría ser útil
        for (uint256 i = 0; i < stakers.length; i++) {
            // ...
        }

        // emite algún evento
    }

    /**
     @notice Distribuir recompensas
     calcula recompensas para el beneficiario indicado 
     */
    function distributeRewards(address beneficiary) private {
        // obtiene el último bloque de punto de control
        uint256 checkpoint = ;

        // calcula recompensas
        // actualiza recompensas pendientes y número de bloque de punto de control
        if (block.number > checkpoint) {
            // recompensa = ver ejemplo más abajo
            uint256 reward = ;
            // ...
        }
    }
}

// Ejemplo de cálculo de recompensas

// REWARD_PER_BLOCK = 1
// bloques-desde-el-último-punto-de-control: 50
// recompensas totales = 50  (50 bloques * 1 recompensa por bloque)
// total staked = 40 (40 tokens LP staked)

// recompensa del usuario = (recompensasTotales/TotalStaked) * usuarioStaked    

// usuario 1: deposita 10, recompensa 12,5
// (50/40)*10 = 12,5

// usuario 2: deposita 30, recompensa 37,5
// (50/40)*30 = 37,5