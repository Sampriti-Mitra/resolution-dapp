const main = async () => {
    const [owner, randomPerson, randomPerson2] = await hre.ethers.getSigners();
    const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
    const waveContract = await waveContractFactory.deploy({
      value: hre.ethers.utils.parseEther("0.1"),
    });
    await waveContract.deployed();
    console.log("Contract deployed to:", waveContract.address);
    console.log("Contract deployed by:", owner.address);

    /*
   * Get Contract balance
   */
    let contractBalance = await hre.ethers.provider.getBalance(
      waveContract.address
    );
    console.log(
      "Contract balance:",
      hre.ethers.utils.formatEther(contractBalance)
    );
    
    let waveCount;
    waveCount = await waveContract.getTotalWaves();
    console.log(waveCount.toNumber());


    let waveTxn = await waveContract.wave("A Message!");
    await waveTxn.wait();

    waveCount = await waveContract.getTotalWaves();

    waveTxn = await waveContract.connect(randomPerson).wave(" A second message!");
    await waveTxn.wait();
  
    waveCount = await waveContract.getTotalWaves();

    waveTxn = await waveContract.connect(randomPerson2).wave(" A third message!");
    await waveTxn.wait();
  
    let allWaves = await waveContract.getAllWaves();
    console.log(allWaves);

    /*
   * Get Contract balance to see what happened!
   */
    contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
    console.log(
      "Contract balance:",
      hre.ethers.utils.formatEther(contractBalance)
    );

    likePosts = await waveContract.connect(randomPerson).likePost(1);
    await likePosts.wait();

    likePosts = await waveContract.connect(randomPerson2).likePost(1);
    await likePosts.wait();

    // this will unlike the previous like since done twice
    likePosts = await waveContract.connect(randomPerson2).likePost(1);
    await likePosts.wait();

    likePosts = await waveContract.likePost(1);
    await likePosts.wait();

    getLikes = await waveContract.getLikesOfPost(1);
    console.log(getLikes);

  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();