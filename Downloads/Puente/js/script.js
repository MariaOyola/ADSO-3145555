// =====================================
// ESCENA
// =====================================

const scene = new THREE.Scene();

scene.background =
    new THREE.Color(0x020617);

scene.fog =
    new THREE.Fog(
        0x020617,
        20,
        70
    );

// =====================================
// CÁMARA
// =====================================

const camera =
    new THREE.PerspectiveCamera(
        60,
        window.innerWidth / window.innerHeight,
        0.1,
        1000
    );

camera.position.set(0, 12, 22);

// =====================================
// RENDER
// =====================================

const renderer =
    new THREE.WebGLRenderer({
        antialias: true
    });

renderer.setSize(
    window.innerWidth,
    window.innerHeight
);

renderer.shadowMap.enabled = true;

document.body.appendChild(
    renderer.domElement
);

// =====================================
// CONTROLES 3D
// =====================================

const controls =
    new THREE.OrbitControls(
        camera,
        renderer.domElement
    );

controls.enableDamping = true;

controls.minDistance = 10;

controls.maxDistance = 45;

// =====================================
// LUCES
// =====================================

const ambientLight =
    new THREE.AmbientLight(
        0x00e5ff,
        1.5
    );

scene.add(ambientLight);

const pointLight =
    new THREE.PointLight(
        0x00bfff,
        4
    );

pointLight.position.set(
    15,
    20,
    10
);

scene.add(pointLight);

// =====================================
// AGUA
// =====================================

const water =
    new THREE.Mesh(

        new THREE.BoxGeometry(
            120,
            0.2,
            60
        ),

        new THREE.MeshStandardMaterial({

            color: 0x001b2e,

            transparent: true,

            opacity: 0.95,

            emissive: 0x00e5ff,

            emissiveIntensity: 0.5,

            metalness: 1,

            roughness: 0.1

        })

    );

water.position.y = -2;

scene.add(water);

// =====================================
// MATERIALES
// =====================================

const towerMaterial =
    new THREE.MeshStandardMaterial({

        color: 0x00bfff,

        emissive: 0x00e5ff,

        emissiveIntensity: 0.8,

        metalness: 1,

        roughness: 0.15

    });

const roadMaterial =
    new THREE.MeshStandardMaterial({

        color: 0x0f172a,

        emissive: 0x00e5ff,

        emissiveIntensity: 0.4,

        metalness: 1,

        roughness: 0.2

    });

// =====================================
// TORRES
// =====================================

function createTower(x) {

    const tower =
        new THREE.Group();

    // CUERPO

    const body =
        new THREE.Mesh(

            new THREE.BoxGeometry(
                5,
                20,
                5
            ),

            towerMaterial

        );

    body.position.y = 10;

    tower.add(body);

    // TECHO

    const roof =
        new THREE.Mesh(

            new THREE.ConeGeometry(
                3.5,
                6,
                4
            ),

            new THREE.MeshStandardMaterial({

                color: 0x7df9ff,

                emissive: 0x00e5ff,

                emissiveIntensity: 1

            })

        );

    roof.position.y = 23;

    roof.rotation.y =
        Math.PI / 4;

    tower.add(roof);

    tower.position.x = x;

    scene.add(tower);

}

createTower(-14);

createTower(14);

// =====================================
// PUENTE SUPERIOR
// =====================================

const topBridge =
    new THREE.Mesh(

        new THREE.BoxGeometry(
            24,
            1,
            4
        ),

        roadMaterial

    );

topBridge.position.set(
    0,
    16,
    0
);

scene.add(topBridge);

// =====================================
// PUENTE IZQUIERDO
// =====================================

const leftGroup =
    new THREE.Group();

scene.add(leftGroup);

const leftBridge =
    new THREE.Mesh(

        new THREE.BoxGeometry(
            10,
            0.7,
            4
        ),

        roadMaterial

    );

leftBridge.position.x = 5;

leftGroup.add(leftBridge);

leftGroup.position.set(
    -5,
    1,
    0
);

// =====================================
// PUENTE DERECHO
// =====================================

const rightGroup =
    new THREE.Group();

scene.add(rightGroup);

const rightBridge =
    new THREE.Mesh(

        new THREE.BoxGeometry(
            10,
            0.7,
            4
        ),

        roadMaterial

    );

rightBridge.position.x = -5;

rightGroup.add(rightBridge);

rightGroup.position.set(
    5,
    1,
    0
);

// =====================================
// LÍNEAS
// =====================================

function addLines(group, dir) {

    for (let i = 0; i < 8; i++) {

        const line =
            new THREE.Mesh(

                new THREE.BoxGeometry(
                    0.6,
                    0.05,
                    0.25
                ),

                new THREE.MeshStandardMaterial({

                    color: 0xffffff,

                    emissive: 0xffffff,

                    emissiveIntensity: 2

                })

            );

        line.position.set(
            dir * (i + 1),
            0.4,
            0
        );

        group.add(line);

    }

}

addLines(leftGroup, 1);

addLines(rightGroup, -1);

// =====================================
// CABLES
// =====================================

function createCable(x1, y1, x2, y2) {

    const material =
        new THREE.LineBasicMaterial({
            color: 0x00e5ff
        });

    const points = [];

    points.push(
        new THREE.Vector3(x1, y1, 0)
    );

    points.push(
        new THREE.Vector3(x2, y2, 0)
    );

    const geometry =
        new THREE.BufferGeometry()
            .setFromPoints(points);

    const line =
        new THREE.Line(
            geometry,
            material
        );

    scene.add(line);

}

createCable(-14, 15, -5, 2);

createCable(14, 15, 5, 2);

// =====================================
// BARCO
// =====================================

const boat =
    new THREE.Group();

scene.add(boat);

// BASE

const boatBase =
    new THREE.Mesh(

        new THREE.BoxGeometry(
            4,
            1,
            2
        ),

        new THREE.MeshStandardMaterial({

            color: 0xff5500,

            emissive: 0xff5500,

            emissiveIntensity: 0.5

        })

    );

boat.add(boatBase);

// CABINA

const cabin =
    new THREE.Mesh(

        new THREE.BoxGeometry(
            1.8,
            1,
            1.5
        ),

        new THREE.MeshStandardMaterial({

            color: 0xffffff,

            emissive: 0x00e5ff,

            emissiveIntensity: 0.3

        })

    );

cabin.position.y = 1;

boat.add(cabin);

// POSICIÓN INICIAL

boat.position.set(
    0,
    -1,
    -30
);

// =====================================
// PERSONAS VISIBLES
// =====================================

const people = [];

function createPerson(x, z) {

    const person =
        new THREE.Group();

    // =================================
    // CUERPO
    // =================================

    const body =
        new THREE.Mesh(

            new THREE.BoxGeometry(
                0.5,
                1,
                0.5
            ),

            new THREE.MeshStandardMaterial({

                color: 0x00e5ff,

                emissive: 0x00e5ff,

                emissiveIntensity: 1

            })

        );

    body.position.y = 0.5;

    person.add(body);

    // =================================
    // CABEZA
    // =================================

    const head =
        new THREE.Mesh(

            new THREE.SphereGeometry(
                0.3,
                32,
                32
            ),

            new THREE.MeshStandardMaterial({

                color: 0xffffff,

                emissive: 0x00e5ff,

                emissiveIntensity: 0.8

            })

        );

    head.position.y = 1.4;

    person.add(head);

    // =================================
    // BRAZO DERECHO
    // =================================

    const arm =
        new THREE.Mesh(

            new THREE.BoxGeometry(
                0.15,
                0.7,
                0.15
            ),

            new THREE.MeshStandardMaterial({

                color: 0x7df9ff,

                emissive: 0x00e5ff,

                emissiveIntensity: 1

            })

        );

    arm.position.set(
        0.4,
        0.8,
        0
    );

    arm.rotation.z =
        -Math.PI / 3;

    person.add(arm);

    // =================================
    // GUARDAR BRAZO
    // =================================

    person.userData.arm = arm;

    // =================================
    // POSICIÓN
    // =================================

    person.position.set(
        x,
        1.5,
        z
    );

    // =================================
    // AGREGAR
    // =================================

    people.push(person);

    boat.add(person);

}

// =====================================
// PERSONAS
// =====================================

createPerson(-0.8, -0.3);

createPerson(0.8, 0.3);
// =====================================
// HUD
// =====================================

const pressureValue =
    document.getElementById(
        "pressureValue"
    );

const forceValue =
    document.getElementById(
        "forceValue"
    );

const heightValue =
    document.getElementById(
        "heightValue"
    );

// =====================================
// ANIMACIÓN
// =====================================

function animate() {

    requestAnimationFrame(
        animate
    );

    // AGUA

    water.material.emissiveIntensity =
        0.45 +
        Math.sin(Date.now() * 0.0015)
        * 0.08;

    // =====================================
    // ANIMACIÓN PERSONAS
    // =====================================

    people.forEach(person => {

        person.userData.arm.rotation.z =
            -Math.PI / 4 +
            Math.sin(Date.now() * 0.005)
            * 0.5;

    });
    // =================================
    // BARCO
    // =================================

    if (boat.position.z < -8) {

        boat.position.z += 0.05;

    }

    else if (
        boat.position.z >= -8 &&
        boat.position.z <= 8
    ) {

        leftGroup.rotation.z += 0.01;

        rightGroup.rotation.z -= 0.01;

        if (
            leftGroup.rotation.z >
            Math.PI / 3
        ) {

            leftGroup.rotation.z =
                Math.PI / 3;

            rightGroup.rotation.z =
                -Math.PI / 3;

            boat.position.z += 0.05;

        }

    }

    else if (boat.position.z > 8) {

        boat.position.z += 0.05;

        if (leftGroup.rotation.z > 0) {

            leftGroup.rotation.z -= 0.01;

            rightGroup.rotation.z += 0.01;

        }

    }

    // REINICIO

    if (boat.position.z > 35) {

        boat.position.z = -30;

    }

    // DATOS HUD

    const pressure =
        Math.floor(
            Math.abs(leftGroup.rotation.z)
            * 100
        );

    pressureValue.innerHTML =
        pressure + " Pa";

    forceValue.innerHTML =
        pressure * 2 + " N";

    heightValue.innerHTML =
        pressure + "%";

    // CONTROLES

    controls.update();

    renderer.render(
        scene,
        camera
    );

}

animate();

// =====================================
// RESPONSIVE
// =====================================

window.addEventListener(
    "resize",
    () => {

        camera.aspect =
            window.innerWidth /
            window.innerHeight;

        camera.updateProjectionMatrix();

        renderer.setSize(
            window.innerWidth,
            window.innerHeight
        );

    }
);